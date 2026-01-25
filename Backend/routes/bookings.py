from fastapi import APIRouter, HTTPException
from db_conection import get_connection
from datetime import datetime, time
from datetime import datetime, timedelta, date, time
from schemas.customer_booking import CustomerBookingsResponse
from schemas.booking import BookingDraftIn, BookingQuoteOut, BookingConfirmIn
from schemas.employee_pending import PendingBookingOut
from schemas.employee_booking_details import EmployeeBookingDetailsOut
from schemas.update_booking_status import BookingStatusUpdateIn
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


def _status_notification(status: str, booking_id: int) -> tuple[str, str]:
    status = status.lower().strip()
    if status in ("approved", "accepted"):
        return (
            "Booking approved",
            f"Your booking #{booking_id} has been approved.",
        )
    if status in ("cancelled", "rejected"):
        return (
            "Booking rejected",
            f"Your booking #{booking_id} has been rejected.",
        )
    if status == "active":
        return (
            "Car pickup confirmed",
            f"Your booking #{booking_id} is now active. Enjoy your ride!",
        )
    if status == "completed":
        return (
            "Rental completed",
            f"Your booking #{booking_id} has been completed. Thank you for choosing CarRental.",
        )
    if status == "pending":
        return (
            "Booking pending",
            f"Your booking #{booking_id} is pending review.",
        )
    return ("Booking update", f"Your booking #{booking_id} status is now '{status}'.")

# first request to know the price of booking
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

# to add the booking after checking all things
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

        days, total, breakdown = calculate_price(
            cur, payload.car_id, payload.start_date, payload.end_date
        )

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

        cur.execute(
            """
            UPDATE cars
            SET status = false
            WHERE id = %s
            """,
            (payload.car_id,)
        )

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

# get for the customer all booking with know the id
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

# get for the employe all care that status is pending 
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
                total_price, r.status, created_at,
                c.image_url
            FROM rentals r
            JOIN cars c ON c.id = r.car_id
            WHERE r.status = 'pending'
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
            "image_url": r[10],
        } for r in rows]

    finally:
        conn.close()


@router.get("/status/{status}", response_model=list[PendingBookingOut])
def get_bookings_by_status(status: str):
    status = status.lower().strip()

    if status in ("accepted",):
        statuses = ("approved", "active", "completed")
    elif status in ("rejected", "cancelled", "canceled"):
        statuses = ("cancelled",)
    elif status in ("pending", "approved", "active", "completed"):
        statuses = (status,)
    else:
        raise HTTPException(
            status_code=400,
            detail="status must be one of pending, accepted, rejected, approved, active, completed, cancelled",
        )

    conn = get_connection()
    try:
        cur = conn.cursor()
        placeholders = ", ".join(["%s"] * len(statuses))
        cur.execute(f"""
            SELECT
                r.id, r.user_id, r.car_id,
                r.pickup_location, r.dropoff_location,
                r.start_date, r.end_date,
                r.total_price, r.status, r.created_at,
                c.image_url
            FROM rentals r
            JOIN cars c ON c.id = r.car_id
            WHERE r.status IN ({placeholders})
            ORDER BY r.id DESC
        """, statuses)

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
            "image_url": r[10],
        } for r in rows]
    finally:
        conn.close()

# show booking details to rject or accept the thing
@router.get("/details/{booking_id}", response_model=EmployeeBookingDetailsOut)
def get_booking_details_for_employee(booking_id: int):
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            SELECT
                r.id,
                r.pickup_location, r.dropoff_location,
                r.start_date, r.end_date,
                r.total_price, r.status,

                u.full_name, u.email, u.phone, u.driving_license_no,

                c.brand, c.model, c.category, c.year, c.status, c.image_url
            FROM rentals r
            JOIN users u ON u.id = r.user_id
            JOIN cars  c ON c.id = r.car_id
            WHERE r.id = %s
            LIMIT 1
        """, (booking_id,))

        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Booking not found")

        return {
            "booking_id": row[0],
            "pickup_location": row[1],
            "dropoff_location": row[2],
            "start_date": row[3],
            "end_date": row[4],
            "total_price": float(row[5]) if row[5] else 0.0,
            "booking_status": row[6],

            "customer": {
                "full_name": row[7],
                "email": row[8],
                "phone": row[9],
                "driving_license_no": row[10],
            },

            "car": {
                "brand": row[11],
                "model": row[12],
                "category": row[13],
                "year": row[14],
                "car_status": bool(row[15]),
                "image_url": row[16],
            }
        }

    finally:
        conn.close()

# get the active for admin if neeed 
@router.get("/active")
def get_active_bookings():
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            SELECT
                r.id,
                r.user_id,
                r.car_id,
                r.pickup_location,
                r.dropoff_location,
                r.start_date,
                r.end_date,
                r.total_price,
                r.status,
                r.created_at
            FROM rentals r
            WHERE r.status = 'active'
            ORDER BY r.start_date ASC
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

@router.put("/{booking_id}/status")
def update_booking_status(booking_id: int, payload: BookingStatusUpdateIn):
    new_status = payload.status.lower().strip()
    employee_id = payload.employee_id

    allowed_statuses = ["pending", "approved", "active", "completed", "cancelled"]
    if new_status not in allowed_statuses:
        raise HTTPException(
            status_code=400,
            detail=f"status must be one of {allowed_statuses}"
        )

    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute(
            "SELECT id, user_id FROM rentals WHERE id=%s LIMIT 1",
            (booking_id,)
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(404, "Booking not found")
        user_id = row[1]

        if employee_id is not None:
            cur.execute(
                "UPDATE rentals SET status=%s, employee_id=%s WHERE id=%s",
                (new_status, employee_id, booking_id)
            )
        else:
            cur.execute(
                "UPDATE rentals SET status=%s WHERE id=%s",
                (new_status, booking_id)
            )

        title, message = _status_notification(new_status, booking_id)
        cur.execute(
            """
            SELECT id FROM notifications
            WHERE user_id=%s AND rental_id=%s AND title=%s
            LIMIT 1
            """,
            (user_id, booking_id, title),
        )
        if not cur.fetchone():
            cur.execute(
                """
                INSERT INTO notifications (user_id, title, message, rental_id, is_read, created_at)
                VALUES (%s, %s, %s, %s, %s, %s)
                """,
                (user_id, title, message, booking_id, 0, datetime.utcnow()),
            )

        conn.commit()

        return {
            "message": "Booking status updated",
            "booking_id": booking_id,
            
            "new_status": new_status
        }

    finally:
        conn.close()
