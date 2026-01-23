from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class CustomerBookingOut(BaseModel):
    brand: str
    model: str
    category: str
    year: int
    car_status: bool
    image_url: Optional[str] = None

    pickup_location: Optional[str] = None
    dropoff_location: Optional[str] = None
    start_date: datetime
    end_date: datetime
    total_price: float
    booking_status: str


class CustomerBookingsResponse(BaseModel):
    customer_id: int
    bookings: List[CustomerBookingOut]
