from fastapi import APIRouter, HTTPException
from fastapi import APIRouter, HTTPException
from db_conection import get_connection
from schemas.car import CarOut, CarCreate, CarUpdate

router = APIRouter(prefix="/admin", tags=["Cars"])

# ===============================
# UPDATE car availability
# ===============================
@router.put("/cars/{car_id}/availability")
def update_car_availability(car_id: int, payload: dict):
    if "status" not in payload:
        raise HTTPException(status_code=400, detail="status is required")

    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(
            "UPDATE cars SET status=%s WHERE id=%s",
            (payload["status"], car_id),
        )
        if cur.rowcount == 0:
            raise HTTPException(status_code=404, detail="Car not found")

        conn.commit()
        return {"message": "Car availability updated", "car_id": car_id}
    finally:
        conn.close()

# ===============================
# GET all cars
# ===============================
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
