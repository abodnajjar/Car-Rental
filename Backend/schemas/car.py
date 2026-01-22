from pydantic import BaseModel
from typing import Optional

class CarOut(BaseModel):
    id: int
    brand: str
    model: str
    category: str
    year: int
    status: bool
    image: Optional[str] = None


class CarCreate(BaseModel):
    brand: str
    model: str
    category: str
    year: int
    status: bool = True
    image: Optional[str] = None


class CarUpdate(BaseModel):
    brand: Optional[str] = None
    model: Optional[str] = None
    category: Optional[str] = None
    year: Optional[int] = None
    status: Optional[bool] = None
    image: Optional[str] = None
