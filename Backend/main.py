from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.staticfiles import StaticFiles
from routes.auth import router as auth_router
from routes.users import router as users_router
from routes.cars import router as cars_router
from fastapi.middleware.cors import CORSMiddleware
from routes.notifications import router as notifications_router
from routes.bookings import router as bookings_router
app = FastAPI(title="Car Rental Backend")



app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:52742", "http://127.0.0.1:52742", "http://localhost:*", "http://127.0.0.1:*", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
app.include_router(auth_router)
app.include_router(users_router)
app.include_router(cars_router)
app.include_router(bookings_router)
app.include_router(notifications_router)
@app.get("/")
def root():
    return {"status": "ok"}
