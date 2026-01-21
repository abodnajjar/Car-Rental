from pydantic import BaseModel
from typing import Optional

class UserOut(BaseModel):
    uid: str
    full_name: str
    email: str
    phone: str
    role: str
    driving_license_no: Optional[str] = None
    salary: Optional[float] = None

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[str] = None
    driving_license_no: Optional[str] = None
    salary: Optional[float] = None