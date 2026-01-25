from typing import Optional
from pydantic import BaseModel

class BookingStatusUpdateIn(BaseModel):
    status: str
    employee_id: Optional[int] = None
