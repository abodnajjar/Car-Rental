from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class PendingBookingOut(BaseModel):
    booking_id: int
    user_id: int
    car_id: int
    pickup_location: Optional[str] = None
    dropoff_location: Optional[str] = None
    start_date: datetime
    end_date: datetime
    total_price: float
    booking_status: str
    created_at: datetime

