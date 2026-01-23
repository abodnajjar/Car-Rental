from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CustomerInfo(BaseModel):
    full_name: str
    email: str
    phone: str
    driving_license_no: Optional[str] = None

class CarInfo(BaseModel):
    brand: str
    model: str
    category: str
    year: int
    car_status: bool
    image_url: Optional[str] = None

class EmployeeBookingDetailsOut(BaseModel):
    booking_id: int
    customer: CustomerInfo
    car: CarInfo

    pickup_location: Optional[str] = None
    dropoff_location: Optional[str] = None
    start_date: datetime
    end_date: datetime
    total_price: float
    booking_status: str
