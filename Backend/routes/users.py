from fastapi import APIRouter, HTTPException
from schemas.user import UserOut, UserUpdate
from db_conection import get_connection

router = APIRouter(prefix="/users", tags=["Users"])


# =====================================================
# GET all employees (Admin page)
# =====================================================



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


# =====================================================
# GET customers count (Dashboard)
# =====================================================


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


# =====================================================
# GET user by id
# =====================================================

# get employee count
@router.get("/employees/count")
def get_employees_count():
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT COUNT(*)
            FROM users
            WHERE role = %s
        """, ("employee",))

        count = cur.fetchone()[0]
        return {"employees_count": count}

    finally:
        conn.close()

# get the user info by user id

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


# =====================================================
# UPDATE user information (general)
# =====================================================



@router.put("/{user_id}", response_model=UserOut)
def update_user(user_id: int, payload: UserUpdate):
    data = payload.model_dump(exclude_none=True)
    if not data:
        raise HTTPException(status_code=400, detail="No fields provided to update")

    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("SELECT id FROM users WHERE id = %s LIMIT 1", (user_id,))
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="User not found")

        set_clause = ", ".join([f"{k}=%s" for k in data.keys()])
        values = list(data.values()) + [user_id]

        query = f"UPDATE users SET {set_clause} WHERE id=%s"
        cur.execute(query, tuple(values))
        conn.commit()

        cur.execute("""
            SELECT id, full_name, email, phone, role, driving_license_no, salary
            FROM users
            WHERE id = %s
            LIMIT 1
        """, (user_id,))
        updated = cur.fetchone()
        conn.commit()  
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


# =====================================================
# ✅ NEW: UPDATE employee salary (Admin only)
# =====================================================
@router.put("/employees/{user_id}/salary", response_model=UserOut)
def update_employee_salary(user_id: int, salary: float):

        
@router.delete("/{user_id}")
def delete_user(user_id: int):

    conn = get_connection()
    try:
        cur = conn.cursor()


        cur.execute("""
            SELECT id
            FROM users
            WHERE id = %s AND role = %s
        """, (user_id, "employee"))

        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Employee not found")

        cur.execute("""
            UPDATE users
            SET salary = %s
            WHERE id = %s
        """, (salary, user_id))

        conn.commit()

        cur.execute("""
            SELECT id, full_name, email, phone, role, driving_license_no, salary
            FROM users
            WHERE id = %s
        """, (user_id,))
        emp = cur.fetchone()

        return {
            "uid": str(emp[0]),
            "full_name": emp[1],
            "email": emp[2],
            "phone": emp[3],
            "role": emp[4],
            "driving_license_no": emp[5],
            "salary": emp[6],
        }

    finally:
        conn.close()

# =====================================================
# 🗑️ NEW: DELETE employee (Admin only)
# =====================================================
@router.delete("/employees/{user_id}")
def delete_employee(user_id: int):
    conn = get_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            SELECT id
            FROM users
            WHERE id = %s AND role = %s
        """, (user_id, "employee"))

        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Employee not found")

        cur.execute("DELETE FROM users WHERE id = %s", (user_id,))
        conn.commit()

        return {"success": True, "message": "Employee deleted successfully"}

    finally:
        conn.close()

        cur.execute(
            "SELECT id FROM users WHERE id = %s LIMIT 1",
            (user_id,)
        )
        user = cur.fetchone()

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        cur.execute(
            "DELETE FROM users WHERE id = %s",
            (user_id,)
        )
        conn.commit()

        return {
            "message": "User deleted successfully",
            "user_id": user_id
        }

    finally:
        conn.close()

