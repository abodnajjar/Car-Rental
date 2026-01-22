from fastapi import APIRouter, HTTPException
from db_conection import get_connection

from schemas.car import CarOut, CarCreate, CarUpdate

router = APIRouter(prefix="/admin", tags=["Cars"])

# ===============================
# GET all cars
# ===============================
from schemas.car import CarOut, CarCreate,CarUpdate

router = APIRouter(tags=["Cars"])
# return the number of cars we have
@router.get("/cars/count")
def cars_count():
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM cars")
        return {"total_cars": cur.fetchone()[0]}
    finally:
        conn.close()

# return all cars 
@router.get("/cars", response_model=list[CarOut])
def get_all_cars():
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT id, brand, model, category, year, status, image
            FROM cars
            ORDER BY id DESC
        """)
        cars = cur.fetchall()

        for c in cars:
            c["status"] = bool(c["status"])

        return cars
    finally:
        conn.close()


# ===============================
# ADD car
# ===============================
@router.post("/cars", response_model=CarOut)
def add_car(car: CarCreate):
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            INSERT INTO cars (brand, model, category, year, status, image)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            car.brand,
            car.model,
            car.category,
            car.year,
            car.status,
            car.image
        ))
        conn.commit()

        car_id = cur.lastrowid
        cur.execute("SELECT * FROM cars WHERE id=%s", (car_id,))
        result = cur.fetchone()
        result["status"] = bool(result["status"])

        return result
    finally:
        conn.close()


# ===============================
# UPDATE car
# ===============================
@router.put("/cars/{car_id}")
def update_car(car_id: int, car: CarUpdate):
    conn = get_connection()
    try:
        cur = conn.cursor()

        fields = []
        values = []

        for key, value in car.dict(exclude_unset=True).items():
            fields.append(f"{key}=%s")
            values.append(value)

        if not fields:
            raise HTTPException(status_code=400, detail="No fields to update")

        values.append(car_id)

        cur.execute(
            f"UPDATE cars SET {', '.join(fields)} WHERE id=%s",
            values
        )
        conn.commit()

        return {"message": "Car updated successfully"}
    finally:
        conn.close()


# ===============================
# DELETE car
# ===============================
@router.delete("/cars/{car_id}")
def delete_car(car_id: int):
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("DELETE FROM cars WHERE id=%s", (car_id,))
        conn.commit()

        return {"message": "Car deleted successfully"}
    finally:
        conn.close()
# add new car
@router.post("/cars", response_model=CarOut, status_code=201)
def add_car(payload: CarCreate):
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            INSERT INTO cars (brand, model, category, year, status, image_url)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            payload.brand,
            payload.model,
            payload.category,
            payload.year,
            1 if payload.status else 0,
            payload.image_url
        ))
        car_id = cur.lastrowid

        for p in payload.prices:
            cur.execute("""
                INSERT INTO car_prices (car_id, day, price)
                VALUES (%s, %s, %s)
            """, (car_id, p.day, p.price))

        conn.commit()

        cur.execute("""
            SELECT id, brand, model, category, year, status, image_url
            FROM cars
            WHERE id = %s
            LIMIT 1
        """, (car_id,))
        c = cur.fetchone()

        cur.execute("""
            SELECT id, day, price
            FROM car_prices
            WHERE car_id = %s
            ORDER BY id ASC
        """, (car_id,))
        price_rows = cur.fetchall()

        prices = [{"id": r[0], "day": r[1], "price": float(r[2])} for r in price_rows]

        return {
            "car_id": c[0],
            "brand": c[1],
            "model": c[2],
            "category": c[3],
            "year": c[4],
            "status": bool(c[5]),
            "image_url": c[6],
            "prices": prices
        }

    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


# update car information
@router.put("/cars/{car_id}", response_model=CarOut)
def update_car(car_id: int, payload: CarUpdate):
    data = payload.model_dump(exclude_none=True)

    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("SELECT id FROM cars WHERE id=%s LIMIT 1", (car_id,))
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Car not found")

        prices_payload = data.pop("prices", None) 

        if "status" in data:
            data["status"] = 1 if data["status"] else 0

        if data:
            set_clause = ", ".join([f"{k}=%s" for k in data.keys()])
            values = list(data.values()) + [car_id]
            cur.execute(f"UPDATE cars SET {set_clause} WHERE id=%s", tuple(values))

        if prices_payload is not None:
            for p in prices_payload:
                cur.execute("""
                    INSERT INTO car_prices (car_id, day, price)
                    VALUES (%s, %s, %s)
                    ON DUPLICATE KEY UPDATE price = VALUES(price)
                """, (car_id, p["day"], p["price"]))

        conn.commit()

        cur.execute("""
            SELECT id, brand, model, category, year, status, image_url
            FROM cars
            WHERE id=%s
            LIMIT 1
        """, (car_id,))
        c = cur.fetchone()

        cur.execute("""
            SELECT id, day, price
            FROM car_prices
            WHERE car_id=%s
            ORDER BY id ASC
        """, (car_id,))
        price_rows = cur.fetchall()

        prices = [{"id": r[0], "day": r[1], "price": float(r[2])} for r in price_rows]

        return {
            "car_id": c[0],
            "brand": c[1],
            "model": c[2],
            "category": c[3],
            "year": c[4],
            "status": bool(c[5]),
            "image_url": c[6],
            "prices": prices
        }

    finally:
        conn.close()


# delete car by id 
@router.delete("/cars/{car_id}")
def delete_car(car_id: int):
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("SELECT id FROM cars WHERE id=%s LIMIT 1", (car_id,))
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Car not found")

        cur.execute("DELETE FROM car_prices WHERE car_id=%s", (car_id,))

        cur.execute("DELETE FROM cars WHERE id=%s", (car_id,))
        conn.commit()

        return {"message": "Car deleted successfully", "car_id": car_id}

    finally:
        conn.close()

