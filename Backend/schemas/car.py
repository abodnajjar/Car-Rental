
from pydantic import BaseModel
from typing import Optional, List
from schemas.car_price import CarPriceOut, CarPriceCreate

class CarOut(BaseModel):
    car_id: int
    brand: str
    model: str
    category: str
    year: int
    status: bool
    image_url: Optional[str] = None
    prices: List[CarPriceOut] = []


class CarCreate(BaseModel):
    brand: str
    model: str
    category: str
    year: int
    status: bool = True
    image_url: Optional[str] = None
    prices: List[CarPriceCreate] = []

class CarUpdate(BaseModel):
    brand: Optional[str] = None
    model: Optional[str] = None
    category: Optional[str] = None
    year: Optional[int] = None
    status: Optional[bool] = None   
    image_url: Optional[str] = None
    prices: List[CarPriceCreate] = []