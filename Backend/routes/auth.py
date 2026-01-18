from fastapi import APIRouter, HTTPException
from schemas.auth import LoginRequest, SignUpRequest
from db_conection import get_connection
import bcrypt

router = APIRouter(prefix="/auth", tags=["auth"])


def _check_password_length(password: str) -> None:

    if len(password.encode("utf-8")) > 72:
        raise HTTPException(
            status_code=400,
            detail="Password is too long (max 72 bytes). Use a shorter password."
        )

def hash_password(password: str) -> str:
    _check_password_length(password)
    hashed = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
    return hashed.decode("utf-8")

def verify_password(password: str, stored_hash: str) -> bool:
    _check_password_length(password)
    try:
        return bcrypt.checkpw(
            password.encode("utf-8"),
            stored_hash.encode("utf-8")
        )
    except ValueError:
        return False


@router.post("/login")
def login(data: LoginRequest):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            """
            SELECT id, full_name, email, role, password_hash
            FROM users
            WHERE email=%s
            LIMIT 1
            """,
            (data.email,),
        )
        user = cursor.fetchone()

        if not user:
            return {"success": False, "message": "Invalid email or password"}

        if not verify_password(data.password, user["password_hash"]):
            return {"success": False, "message": "Invalid email or password"}

        return {
            "success": True,
            "message": "Login successful",
            "user_id": user["id"],
            "full_name": user["full_name"],
            "role": user["role"],
        }

    finally:
        cursor.close()
        conn.close()


@router.post("/signup")
def signup(body: SignUpRequest):
    if body.role == "employee":
        if body.salary is None:
            raise HTTPException(status_code=400, detail="Salary is required for employee signup.")
    elif body.role == "customer":
        pass

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id FROM users WHERE email=%s", (body.email,))
        if cursor.fetchone():
            raise HTTPException(status_code=409, detail="Email already exists")

        password_hash = hash_password(body.password)

        cursor.execute(
            """
            INSERT INTO users
            (full_name, email, phone, role, password_hash, driving_license_no, salary)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                body.full_name,
                body.email,
                body.phone,
                body.role,
                password_hash,
                body.driving_license_no,
                body.salary,
            ),
        )

        conn.commit()
        user_id = cursor.lastrowid
        return {"message": "Signup successful", "user_id": user_id}

    finally:
        cursor.close()
        conn.close()
