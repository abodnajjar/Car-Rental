from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class NotificationCreate(BaseModel):
    user_id: int
    title: str = Field(min_length=1, max_length=100)
    message: str = Field(min_length=1)
    rental_id: Optional[int] = None



class NotificationUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=100)
    message: Optional[str] = Field(default=None, min_length=1)
    is_read: Optional[bool] = None
    rental_id: Optional[int] = None


class NotificationOut(BaseModel):
    id: int
    user_id: int
    title: Optional[str] = None
    message: Optional[str] = None
    is_read: bool
    created_at: datetime
    rental_id: Optional[int] = None