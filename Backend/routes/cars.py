from fastapi import APIRouter
from db_conection import get_connection
from schemas.car import CarOut

router = APIRouter(tags=["Cars"])


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
