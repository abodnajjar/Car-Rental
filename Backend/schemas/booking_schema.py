from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class BookingOut(BaseModel):
    id: int
    user_id: int
    employee_id: Optional[int] = None
    car_id: int

    pickup_location: Optional[str] = None
    dropoff_location: Optional[str] = None

    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None

    total_price: Optional[float] = None
    status: str
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
