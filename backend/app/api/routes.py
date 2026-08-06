from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile

from app.config import Settings, get_settings
from app.providers.gemini import GeminiProvider, GeminiProviderError
from app.schemas.places import (
    HealthResponse,
    NearbyPlacesResult,
    PlaceContext,
    PlaceDetailContent,
    PlaceRecognitionResult,
)
from app.services.places import PlaceService

router = APIRouter()


def get_place_service(settings: Settings = Depends(get_settings)) -> PlaceService:
    return PlaceService(provider=GeminiProvider(settings), settings=settings)


@router.get("/health", response_model=HealthResponse)
async def health(settings: Settings = Depends(get_settings)) -> HealthResponse:
    return HealthResponse(
        status="ok",
        service=settings.app_name,
        environment=settings.app_env,
        promptVersions={
            "analyze": settings.prompt_version_analyze,
            "details": settings.prompt_version_details,
            "nearby": settings.prompt_version_nearby,
        },
    )


@router.post("/v1/places/analyze", response_model=PlaceRecognitionResult)
async def analyze_place(
    image: UploadFile = File(...),
    language: str = Form(default="English"),
    latitude: Optional[float] = Form(default=None),
    longitude: Optional[float] = Form(default=None),
    location_source: Optional[str] = Form(default=None),
    service: PlaceService = Depends(get_place_service),
) -> PlaceRecognitionResult:
    try:
        return await service.analyze(
            image=image,
            language=language,
            latitude=latitude,
            longitude=longitude,
            location_source=location_source,
        )
    except GeminiProviderError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc


@router.post("/v1/places/details", response_model=PlaceDetailContent)
async def place_details(
    place: PlaceContext,
    service: PlaceService = Depends(get_place_service),
) -> PlaceDetailContent:
    try:
        return await service.details(place)
    except GeminiProviderError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc


@router.post("/v1/places/nearby", response_model=NearbyPlacesResult)
async def nearby_places(
    place: PlaceContext,
    service: PlaceService = Depends(get_place_service),
) -> NearbyPlacesResult:
    try:
        return await service.nearby(place)
    except GeminiProviderError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
