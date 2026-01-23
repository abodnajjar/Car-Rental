from datetime import date
from pydantic import BaseModel
from typing import List
from typing import Optional
from datetime import datetime

class BookingDraftIn(BaseModel):
    user_id: int
    car_id: int
    pickup_location: str
    dropoff_location: str
    start_date: date
    end_date: date

class PriceBreakdownOut(BaseModel):
    day: str
    price: float

class BookingQuoteOut(BaseModel):
    days: int
    total_price: float
    breakdown: List[PriceBreakdownOut]

class BookingConfirmIn(BookingDraftIn):
    payment_method: str  # cash / visa

class BookingOut(BaseModel):
    booking_id: int
    user_id: int
    employee_id: Optional[int] = None
    car_id: int
    pickup_location: Optional[str] = None
    dropoff_location: Optional[str] = None
    start_date: datetime
    end_date: datetime
    total_price: float
    status: str
    created_at: datetime

    