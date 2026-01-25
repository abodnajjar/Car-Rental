from unittest import result
from fastapi import APIRouter, HTTPException
from db_conection import get_connection
from schemas.car import CarOut, CarCreate,CarUpdate
from fastapi import UploadFile, File, HTTPException
import os, shutil
UPLOAD_DIR = "uploads/cars"
os.makedirs(UPLOAD_DIR, exist_ok=True)
router = APIRouter(tags=["Cars"])
@router.get("/cars/count")
def cars_count():
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM cars")
        return {"total_cars": cur.fetchone()[0]}
    finally:
        conn.close()


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

@router.get("/cars", response_model=list[CarOut])
def get_all_cars():
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            SELECT id, brand, model, category, year, status, image_url
            FROM cars
            ORDER BY id DESC
        """)
        cars_rows = cur.fetchall()

        result = []
        for c in cars_rows:
            car_id = c[0]  

            cur.execute("""
                SELECT id, day, price
                FROM car_prices
                WHERE car_id = %s
                ORDER BY id ASC
            """, (car_id,))
            price_rows = cur.fetchall()

            prices = []
            for p in price_rows:
                prices.append({
                    "id": p[0],
                    "day": p[1],
                    "price": float(p[2]),
                })
 
            result.append({
                "car_id": c[0],         
                "brand": c[1],
                "model": c[2],
                "category": c[3],
                "year": c[4],
                "status": bool(c[5]),
                "image_url": c[6],
                "prices": prices
            })

        return result

    finally:
        conn.close()
        
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


@router.get("/cars/available", response_model=list[CarOut])
def get_available_cars():
    """Get only available cars (for customers)"""
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            SELECT id, brand, model, category, year, status, image_url
            FROM cars
            WHERE status = true
            ORDER BY id DESC
        """)
        cars_rows = cur.fetchall()

        result = []
        for c in cars_rows:
            car_id = c[0]  

            cur.execute("""
                SELECT id, day, price
                FROM car_prices
                WHERE car_id = %s
                ORDER BY id ASC
            """, (car_id,))
            price_rows = cur.fetchall()

            prices = []
            for p in price_rows:
                prices.append({
                    "id": p[0],
                    "day": p[1],
                    "price": float(p[2]),
                })

            result.append({
                "car_id": c[0],         
                "brand": c[1],
                "model": c[2],
                "category": c[3],
                "year": c[4],
                "status": bool(c[5]),
                "image_url": c[6],
                "prices": prices
            })

        return result

    finally:
        conn.close()

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
# upload car image
@router.post("/cars/{car_id}/image")
def upload_car_image(car_id: int, image: UploadFile = File(...)):

    ext = os.path.splitext(image.filename)[1].lower()
    if ext not in [".jpg", ".jpeg", ".png", ".webp"]:
        raise HTTPException(status_code=400, detail="Unsupported image type")

    filename = f"{car_id}.jpg"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(image.file, buffer)

    # 👇 نخزن فقط اسم الملف
    image_url = filename

    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(
            "UPDATE cars SET image_url=%s WHERE id=%s",
            (image_url, car_id)
        )
        conn.commit()
    finally:
        conn.close()

    return {"image_url": image_url}

# get car prices

@router.get("/admin/cars/{car_id}/prices")
def get_car_prices(car_id: int):
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            SELECT id, day, price
            FROM car_prices
            WHERE car_id=%s
            ORDER BY id ASC
        """, (car_id,))
        rows = cur.fetchall()

        return [
            {
                "id": r[0],
                "day": r[1],
                "price": float(r[2])
            }
            for r in rows
        ]

    finally:
        conn.close()
    # update car price
@router.put("/admin/cars/{car_id}/prices")
def update_car_price(car_id: int, payload: dict):
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            UPDATE car_prices
            SET price=%s
            WHERE car_id=%s AND day=%s
        """, (payload["price"], car_id, payload["day"]))

        conn.commit()

        return {"message": "Price updated"}

    finally:
        conn.close()
