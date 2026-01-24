from pydantic import BaseModel

class CarPriceOut(BaseModel):
    id: int
    day: str
    price: float

class CarPriceCreate(BaseModel):
    day: str
    price: float

class CarPriceUpdate(BaseModel):
    day: str | None = None
    price: float | None = None