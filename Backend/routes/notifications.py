from datetime import datetime, timedelta
from typing import Optional

from fastapi import APIRouter, HTTPException, Query, status

from db_conection import get_connection
from schemas.notifcations import NotificationCreate, NotificationOut, NotificationUpdate

router = APIRouter(prefix="/notifications", tags=["Notifications"])


def _utcnow() -> datetime:
    return datetime.utcnow()


@router.post("", response_model=NotificationOut, status_code=status.HTTP_201_CREATED)
def add_notification(payload: NotificationCreate):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        created_at = _utcnow()
        cur.execute(
            """
            INSERT INTO notifications (user_id, title, message, rental_id, is_read, created_at)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (payload.user_id, payload.title, payload.message, payload.rental_id, 0, created_at),
        )
        conn.commit()

        notification_id = cur.lastrowid
        cur.execute(
            """
            SELECT id, user_id, title, message, rental_id, is_read, created_at
            FROM notifications
            WHERE id = %s
            """,
            (notification_id,),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=500, detail="Failed to create notification")

        row["is_read"] = bool(row["is_read"])
        return row
    finally:
        cur.close()
        conn.close()


@router.get("", response_model=list[NotificationOut])
def list_notifications(
    user_id: Optional[int] = Query(default=None),
    is_read: Optional[bool] = Query(default=None),
    rental_id: Optional[int] = Query(default=None),
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        where = []
        params: list[object] = []

        if user_id is not None:
            where.append("user_id = %s")
            params.append(user_id)

        if is_read is not None:
            where.append("is_read = %s")
            params.append(1 if is_read else 0)

        if rental_id is not None:
            where.append("rental_id = %s")
            params.append(rental_id)

        sql = """
            SELECT id, user_id, title, message, rental_id, is_read, created_at
            FROM notifications
        """
        if where:
            sql += " WHERE " + " AND ".join(where)

        sql += " ORDER BY id DESC LIMIT %s OFFSET %s"
        params.extend([limit, offset])

        cur.execute(sql, tuple(params))
        rows = cur.fetchall() or []
        for r in rows:
            r["is_read"] = bool(r["is_read"])
        return rows
    finally:
        cur.close()
        conn.close()


@router.get("/unread_count")
def unread_count(
    user_id: int = Query(..., description="User id to count unread notifications for"),
):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute(
            """
            SELECT COUNT(*) AS cnt
            FROM notifications
            WHERE user_id = %s AND is_read = 0
            """,
            (user_id,),
        )
        row = cur.fetchone() or {"cnt": 0}
        return {"user_id": user_id, "unread_count": int(row["cnt"])}
    finally:
        cur.close()
        conn.close()


@router.get("/{notification_id}", response_model=NotificationOut)
def get_notification_by_id(notification_id: int):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute(
            """
            SELECT id, user_id, title, message, rental_id, is_read, created_at
            FROM notifications
            WHERE id = %s
            """,
            (notification_id,),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Notification not found")

        row["is_read"] = bool(row["is_read"])
        return row
    finally:
        cur.close()
        conn.close()


@router.patch("/{notification_id}", response_model=NotificationOut)
def update_notification(notification_id: int, payload: NotificationUpdate):
    data = payload.model_dump(exclude_none=True)
    if not data:
        raise HTTPException(status_code=400, detail="No fields provided")

    if "is_read" in data:
        data["is_read"] = 1 if data["is_read"] else 0

    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute("SELECT id FROM notifications WHERE id = %s LIMIT 1", (notification_id,))
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Notification not found")

        set_clause = ", ".join([f"{k}=%s" for k in data.keys()])
        values = list(data.values()) + [notification_id]

        cur.execute(f"UPDATE notifications SET {set_clause} WHERE id = %s", tuple(values))
        conn.commit()

        cur.execute(
            """
            SELECT id, user_id, title, message, rental_id, is_read, created_at
            FROM notifications
            WHERE id = %s
            """,
            (notification_id,),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=500, detail="Failed to load updated notification")

        row["is_read"] = bool(row["is_read"])
        return row
    finally:
        cur.close()
        conn.close()


@router.post("/reminders", response_model=list[NotificationOut])
def create_and_get_reminder_notifications(
    user_id: Optional[int] = Query(default=None, description="If provided, only create reminders for this user"),
    days_before: int = Query(default=2, ge=1, le=30),
):

    now = _utcnow()
    until = now + timedelta(days=days_before)

    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        rental_sql = """
            SELECT id, user_id, end_date
            FROM rentals
            WHERE end_date IS NOT NULL
              AND end_date >= %s
              AND end_date <= %s
        """
        params: list[object] = [now, until]
        if user_id is not None:
            rental_sql += " AND user_id = %s"
            params.append(user_id)

        cur.execute(rental_sql, tuple(params))
        rentals = cur.fetchall() or []

        results: list[dict] = []
        for r in rentals:
            time_left = r["end_date"] - now
            if time_left.total_seconds() <= 0:
                continue

            if time_left < timedelta(days=1):
                message = (
                    f"Your rental (id={r['id']}) ends in less than 24 hours."
                )
            else:
                days_left = int(time_left.total_seconds() // 86400)
                if days_left < 1:
                    days_left = 1
                message = (
                    f"Your rental (id={r['id']}) will end in about {days_left} day(s) "
                    f"on {r['end_date']}."
                )

            title = "Rental ending soon"

            # DEDUPE by rental_id (much safer than by message text)
            cur.execute(
                """
                SELECT id, user_id, title, message, rental_id, is_read, created_at
                FROM notifications
                WHERE user_id = %s AND rental_id = %s AND title = %s
                LIMIT 1
                """,
                (r["user_id"], r["id"], title),
            )
            existing = cur.fetchone()
            if existing:
                existing["is_read"] = bool(existing["is_read"])
                results.append(existing)
                continue

            cur.execute(
                """
                INSERT INTO notifications (user_id, title, message, rental_id, is_read, created_at)
                VALUES (%s, %s, %s, %s, %s, %s)
                """,
                (r["user_id"], title, message, r["id"], 0, now),
            )
            new_id = cur.lastrowid

            cur.execute(
                """
                SELECT id, user_id, title, message, rental_id, is_read, created_at
                FROM notifications
                WHERE id = %s
                """,
                (new_id,),
            )
            created = cur.fetchone()
            if created:
                created["is_read"] = bool(created["is_read"])
                results.append(created)

        conn.commit()
        return results
    finally:
        cur.close()
        conn.close()
