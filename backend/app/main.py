from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .config import settings
from .database import engine, Base
from .routers import auth, clubs, reviews, favourites, users

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="NightPulse API",
    description="Real-time nightlife discovery API",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(clubs.router)
app.include_router(reviews.router)
app.include_router(favourites.router)
app.include_router(users.router)


APP_VERSION = "1.0.0"
MIN_APP_VERSION = "1.0.0"


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/version")
def version():
    return {
        "current_version": APP_VERSION,
        "min_version": MIN_APP_VERSION,
        "update_url": "https://nightpulseweb.z28.web.core.windows.net/nightpulse.apk",
    }
