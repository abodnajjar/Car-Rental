from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from routes.auth import router as auth_router
from routes.users import router as users_router
from routes.cars import router as cars_router
from routes.dashboard_routes import router as dashboard_router
from routes.notifications import router as notifications_router
from routes.bookings import router as bookings_router
from routes.bookings_admin_routes import router as bookings_admin_router

import os

app = FastAPI(title="Car Rental Backend")

# =========================
# CORS (مهم جداً)
# =========================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # للتطوير فقط
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# Uploads Folder
# =========================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_DIR = os.path.join(BASE_DIR, "uploads")

app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# =========================
# Routers
# =========================
app.include_router(auth_router)
app.include_router(users_router)
app.include_router(cars_router)
app.include_router(bookings_router)
app.include_router(notifications_router)
app.include_router(bookings_admin_router)
app.include_router(dashboard_router)

# =========================
# Root
# =========================
@app.get("/")
def root():
    return {"status": "ok"}
