from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Optional

from app.schemas.places import NearbyPlacesResult, PlaceContext, PlaceDetailContent, PlaceRecognitionResult


class AIProvider(ABC):
    """Provider-agnostic interface so Gemini can be swapped later."""

    @abstractmethod
    async def analyze_place(
        self,
        *,
        image_bytes: bytes,
        mime_type: str,
        language: str,
        latitude: Optional[float],
        longitude: Optional[float],
        location_source: Optional[str],
    ) -> PlaceRecognitionResult:
        raise NotImplementedError

    @abstractmethod
    async def fetch_place_details(self, place: PlaceContext) -> PlaceDetailContent:
        raise NotImplementedError

    @abstractmethod
    async def fetch_nearby_places(self, place: PlaceContext) -> NearbyPlacesResult:
        raise NotImplementedError
