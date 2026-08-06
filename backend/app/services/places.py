from __future__ import annotations

from typing import Optional, Tuple

from fastapi import HTTPException, UploadFile

from app.config import Settings
from app.providers.base import AIProvider
from app.schemas.places import NearbyPlacesResult, PlaceContext, PlaceDetailContent, PlaceRecognitionResult

ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/heic",
    "image/heif",
    "image/webp",
}


class PlaceService:
    def __init__(self, provider: AIProvider, settings: Settings) -> None:
        self._provider = provider
        self._settings = settings

    async def analyze(
        self,
        *,
        image: UploadFile,
        language: str,
        latitude: Optional[float],
        longitude: Optional[float],
        location_source: Optional[str],
    ) -> PlaceRecognitionResult:
        image_bytes, mime_type = await self._read_image(image)
        return await self._provider.analyze_place(
            image_bytes=image_bytes,
            mime_type=mime_type,
            language=language,
            latitude=latitude,
            longitude=longitude,
            location_source=location_source,
        )

    async def details(self, place: PlaceContext) -> PlaceDetailContent:
        return await self._provider.fetch_place_details(place)

    async def nearby(self, place: PlaceContext) -> NearbyPlacesResult:
        return await self._provider.fetch_nearby_places(place)

    async def _read_image(self, image: UploadFile) -> Tuple[bytes, str]:
        mime_type = (image.content_type or "").lower()
        if mime_type not in ALLOWED_MIME_TYPES:
            raise HTTPException(
                status_code=400,
                detail="Unsupported image type. Use JPEG, PNG, HEIC, or WebP.",
            )

        image_bytes = await image.read()
        if not image_bytes:
            raise HTTPException(status_code=400, detail="Empty image upload.")

        if len(image_bytes) > self._settings.max_image_bytes:
            raise HTTPException(
                status_code=413,
                detail=f"Image is too large. Maximum size is {self._settings.max_image_bytes} bytes.",
            )

        return image_bytes, mime_type
