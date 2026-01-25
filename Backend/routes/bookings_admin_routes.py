from fastapi import APIRouter, HTTPException
from typing import List
from db_conection import get_connection

from schemas.booking_schema import BookingOut  # عدّل الاسم حسب ملفك

router = APIRouter(prefix="/admin/bookings", tags=["Admin Bookings"])

@router.get("", response_model=List[BookingOut])
def get_all_bookings():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
              id, user_id, employee_id, car_id,
              pickup_location, dropoff_location,
              start_date, end_date, total_price,
              status, created_at
            FROM rentals
            ORDER BY created_at DESC
        """)
        rows = cursor.fetchall()

        cursor.close()
        conn.close()

        return rows

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
