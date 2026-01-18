from pydantic import BaseModel, EmailStr
from typing import Optional

class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class SignUpRequest(BaseModel):
    full_name: str
    email: EmailStr
    phone: Optional[str] = None
    role: str
    password: str
    driving_license_no: Optional[str] = None
    salary: Optional[float] = None   