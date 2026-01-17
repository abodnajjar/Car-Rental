from fastapi import APIRouter
from app.db import get_connection
from app.schemas.auth import LoginRequest
from passlib.context import CryptContext

router = APIRouter(prefix="/auth", tags=["auth"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@router.post("/login")
def login(data: LoginRequest):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, full_name, email, role, password_hash
                FROM users
                WHERE email=%s
                LIMIT 1
                """,
                (data.email,)
            )
            user = cursor.fetchone()

            if not user:
                return {"success": False, "message": "Invalid email or password"}

            # تحقق من كلمة السر مع bcrypt hash
            if not pwd_context.verify(data.password, user["password_hash"]):
                return {"success": False, "message": "Invalid email or password"}

        return {
            "success": True,
            "message": "Login successful",
            "user_id": user["id"],
            "full_name": user["full_name"],
            "role": user["role"]
        }
    finally:
        conn.close()
