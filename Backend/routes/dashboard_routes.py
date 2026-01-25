from fastapi import APIRouter
from db_conection import get_connection

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])

@router.get("")
def get_dashboard_stats():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT COUNT(*) AS total_cars FROM cars")
    total_cars = cursor.fetchone()["total_cars"]

    cursor.execute("SELECT COUNT(*) AS total_bookings FROM rentals")
    total_bookings = cursor.fetchone()["total_bookings"]

    cursor.execute("SELECT COUNT(*) AS total_customers FROM users WHERE role='customer'")
    total_customers = cursor.fetchone()["total_customers"]

    cursor.execute("SELECT IFNULL(SUM(total_price),0) AS revenue FROM rentals WHERE status='completed'")
    revenue = cursor.fetchone()["revenue"]

    # Monthly profit (آخر 12 شهر)
    cursor.execute("""
        SELECT MONTH(created_at) AS month,
               IFNULL(SUM(total_price),0) AS profit
        FROM rentals
        WHERE status='completed'
        GROUP BY MONTH(created_at)
        ORDER BY month
    """)
    rows = cursor.fetchall()

    monthly_profit = [0] * 12
    for row in rows:
        monthly_profit[row["month"] - 1] = float(row["profit"])

    cursor.close()
    conn.close()

    return {
        "total_cars": total_cars,
        "bookings": total_bookings,
        "customers": total_customers,
        "revenue": float(revenue),
        "monthly_profit": monthly_profit
    }
