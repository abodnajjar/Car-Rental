from fastapi import APIRouter, HTTPException
from db_conection import get_connection
from schemas.car_price import CarPriceOut, CarPriceUpdate

router = APIRouter(prefix="/admin", tags=["Car Prices"])


@router.get("/cars/{car_id}/prices", response_model=list[CarPriceOut])
def get_car_prices(car_id: int):
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT id, day, price
            FROM car_prices
            WHERE car_id = %s
            ORDER BY FIELD(day,
                'monday','tuesday','wednesday','thursday',
                'friday','saturday','sunday'
            )
        """, (car_id,))
        prices = cur.fetchall()

        if not prices:
            raise HTTPException(
                status_code=404,
                detail="No prices found for this car"
            )

        return prices
    finally:
        conn.close()


@router.put("/cars/{car_id}/prices")
def update_car_price(car_id: int, data: CarPriceUpdate):
    if data.price < 50 or data.price > 10000:
        raise HTTPException(
            status_code=400,
            detail="Price must be between 50 and 10000"
        )

    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            UPDATE car_prices
            SET price = %s
            WHERE car_id = %s AND day = %s
        """, (
            data.price,
            car_id,
            data.day
        ))
        conn.commit()

        if cur.rowcount == 0:
            raise HTTPException(
                status_code=404,
                detail="Price not found for this day"
            )

        return {"message": "Car price updated successfully"}
    finally:
        conn.close()
