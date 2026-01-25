from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class BookingDetailsOut(BaseModel):
    booking_id: int
    user_id: int
    employee_id: Optional[int] = None
    car_id: int
    car_name: str
    pickup_location: Optional[str] = None
    dropoff_location: Optional[str] = None
    start_date: datetime
    end_date: datetime
    total_price: float
    status: str
    created_at: datetime
