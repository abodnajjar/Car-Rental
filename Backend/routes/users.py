from fastapi import APIRouter, HTTPException
from schemas.user import UserOut, UserUpdate
from db_conection import get_connection

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/employees", response_model=list[UserOut])
def get_employees():
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT id, full_name, email, phone, role, driving_license_no, salary
            FROM users
            WHERE role = %s
            ORDER BY id DESC
        """, ("employee",))

        rows = cur.fetchall()

        return [{
            "uid": str(r[0]),
            "full_name": r[1],
            "email": r[2],
            "phone": r[3],
            "role": r[4],
            "driving_license_no": r[5],
            "salary": r[6],
        } for r in rows]

    finally:
        conn.close()


@router.get("/customers/count")
def get_customers_count():
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT COUNT(*)
            FROM users
            WHERE role = %s
        """, ("customer",))

        count = cur.fetchone()[0]
        return {"customers_count": count}

    finally:
        conn.close()


@router.get("/{user_id}", response_model=UserOut)
def get_user_by_id(user_id: int):
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT id, full_name, email, phone, role, driving_license_no, salary
            FROM users
            WHERE id = %s
            LIMIT 1
        """, (user_id,))

        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "uid": str(row[0]),
            "full_name": row[1],
            "email": row[2],
            "phone": row[3],
            "role": row[4],
            "driving_license_no": row[5],
            "salary": row[6],
        }

    finally:
        conn.close()


@router.put("/{user_id}", response_model=UserOut)
def update_user(user_id: int, payload: UserUpdate):
    data = payload.model_dump(exclude_none=True)
    if not data:
        raise HTTPException(status_code=400, detail="No fields provided to update")

    conn = get_connection()
    try:
        cur = conn.cursor()

        # check exists
        cur.execute("SELECT id FROM users WHERE id = %s LIMIT 1", (user_id,))
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="User not found")

        # build update query
        set_parts = []
        for key in data.keys():
            set_parts.append(f"{key}=%s")

        set_clause = ", ".join(set_parts)
        values = list(data.values()) + [user_id]

        query = f"UPDATE users SET {set_clause} WHERE id=%s"
        cur.execute(query, tuple(values))

        # return updated
        cur.execute("""
            SELECT id, full_name, email, phone, role, driving_license_no, salary
            FROM users
            WHERE id = %s
            LIMIT 1
        """, (user_id,))
        updated = cur.fetchone()

        return {
            "uid": str(updated[0]),
            "full_name": updated[1],
            "email": updated[2],
            "phone": updated[3],
            "role": updated[4],
            "driving_license_no": updated[5],
            "salary": updated[6],
        }

    finally:
        conn.close()
