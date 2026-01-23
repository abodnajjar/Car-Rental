from pydantic import BaseModel

class BookingStatusUpdateIn(BaseModel):
    status: str
