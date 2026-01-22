from fastapi import APIRouter, HTTPException
from db_conection import get_connection
from datetime import datetime, timedelta, date, time
from schemas.customer_booking import CustomerBookingsResponse
from schemas.booking import BookingDraftIn, BookingQuoteOut, BookingConfirmIn
from schemas.employee_pending import PendingBookingOut
router = APIRouter(prefix="/bookings", tags=["Bookings"])

DAY_NAMES = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]


def validate_booking_date(start_date: date):
    max_days_ahead = 7
    today = date.today()

    if start_date < today:
        raise HTTPException(400, "start_date must be today or later")

    if start_date > today + timedelta(days=max_days_ahead):
        raise HTTPException(400, f"You can book only within {max_days_ahead} days ahead")


def get_days_between(start_date: date, end_date: date):
    if end_date <= start_date:
        raise HTTPException(400, "end_date must be after start_date")

    days = []
    d = start_date
    while d < end_date:
        days.append(d)
        d = d + timedelta(days=1)
    return days


def check_car_available(cur, car_id: int, start_dt: datetime, end_dt: datetime):
    cur.execute(
        """
        SELECT id FROM rentals
        WHERE car_id=%s
          AND status IN ('pending','approved')
          AND NOT (end_date <= %s OR start_date >= %s)
        LIMIT 1
        """,
        (car_id, start_dt, end_dt),
    )
    if cur.fetchone():
        raise HTTPException(400, "Car is not available in this date range")


def calculate_price(cur, car_id: int, start_date: date, end_date: date):
    days = get_days_between(start_date, end_date)

    total = 0.0
    breakdown = []

    for d in days:
        day_name = DAY_NAMES[d.weekday()]

        cur.execute(
            """
            SELECT price FROM car_prices
            WHERE car_id=%s AND day=%s
            LIMIT 1
            """,
            (car_id, day_name),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(400, f"Missing price for day '{day_name}'")

        price = float(row[0])
        breakdown.append({"day": day_name, "price": price})
        total += price

    return len(days), total, breakdown


@router.post("/price", response_model=BookingQuoteOut)
def price_booking(payload: BookingDraftIn):
    validate_booking_date(payload.start_date)

    start_dt = datetime.combine(payload.start_date, time.min)
    end_dt = datetime.combine(payload.end_date, time.min)

    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("SELECT id FROM cars WHERE id=%s LIMIT 1", (payload.car_id,))
        if not cur.fetchone():
            raise HTTPException(404, "Car not found")

        check_car_available(cur, payload.car_id, start_dt, end_dt)

        days, total, breakdown = calculate_price(cur, payload.car_id, payload.start_date, payload.end_date)

        return {"days": days, "total_price": total, "breakdown": breakdown}

    finally:
        conn.close()


@router.post("/confirm")
def confirm_booking(payload: BookingConfirmIn):
    validate_booking_date(payload.start_date)

    method = payload.payment_method.lower().strip()
    if method not in ("cash", "visa"):
        raise HTTPException(400, "payment_method must be 'cash' or 'visa'")

    start_dt = datetime.combine(payload.start_date, time.min)
    end_dt = datetime.combine(payload.end_date, time.min)

    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("SELECT id FROM cars WHERE id=%s LIMIT 1", (payload.car_id,))
        if not cur.fetchone():
            raise HTTPException(404, "Car not found")

        check_car_available(cur, payload.car_id, start_dt, end_dt)

        days, total, breakdown = calculate_price(cur, payload.car_id, payload.start_date, payload.end_date)

        cur.execute(
            """
            INSERT INTO rentals (
                user_id, employee_id, car_id,
                pickup_location, dropoff_location,
                start_date, end_date,
                total_price, status
            )
            VALUES (%s, NULL, %s, %s, %s, %s, %s, %s, 'pending')
            """,
            (
                payload.user_id,
                payload.car_id,
                payload.pickup_location,
                payload.dropoff_location,
                start_dt,
                end_dt,
                total,
            ),
        )

        booking_id = cur.lastrowid
        payment_status = "pending" if method == "cash" else "paid"

        cur.execute(
            """
            INSERT INTO payments (
                rental_id, user_id, amount,
                payment_method, payment_status
            )
            VALUES (%s, %s, %s, %s, %s)
            """,
            (booking_id, payload.user_id, total, method, payment_status),
        )

        conn.commit()

        return {
            "message": "Booking created",
            "booking_id": booking_id,
            "total_price": total,
            "status": "pending",
            "payment_status": payment_status,
        }

    finally:
        conn.close()

@router.get("/customer/{customer_id}", response_model=CustomerBookingsResponse)
def get_customer_bookings(customer_id: int):
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            SELECT
                c.brand,
                c.model,
                c.category,
                c.year,
                c.status AS car_status,
                c.image_url,

                r.pickup_location,
                r.dropoff_location,
                r.start_date,
                r.end_date,
                r.total_price,
                r.status AS booking_status
            FROM rentals r
            JOIN cars c ON c.id = r.car_id
            WHERE r.user_id = %s
            ORDER BY r.id DESC
        """, (customer_id,))

        rows = cur.fetchall()

        bookings = []
        for r in rows:
            bookings.append({
                "brand": r[0],
                "model": r[1],
                "category": r[2],
                "year": r[3],
                "car_status": bool(r[4]),
                "image_url": r[5],

                "pickup_location": r[6],
                "dropoff_location": r[7],
                "start_date": r[8],
                "end_date": r[9],
                "total_price": float(r[10]) if r[10] else 0.0,
                "booking_status": r[11],
            })

        return {
            "customer_id": customer_id,
            "bookings": bookings
        }

    finally:
        conn.close()

@router.get("/pending", response_model=list[PendingBookingOut])
def get_pending_bookings():
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT
                id, user_id, car_id,
                pickup_location, dropoff_location,
                start_date, end_date,
                total_price, status, created_at
            FROM rentals
            WHERE status = 'pending'
            ORDER BY id DESC
        """)
        rows = cur.fetchall()

        return [{
            "booking_id": r[0],
            "user_id": r[1],
            "car_id": r[2],
            "pickup_location": r[3],
            "dropoff_location": r[4],
            "start_date": r[5],
            "end_date": r[6],
            "total_price": float(r[7]) if r[7] else 0.0,
            "booking_status": r[8],
            "created_at": r[9],
        } for r in rows]

    finally:
        conn.close()

