from __future__ import annotations

from fastapi import FastAPI

from app.api.routes import router
from app.config import get_settings

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    description="Backend API for Travel AI place recognition and guide content.",
)

app.include_router(router)
