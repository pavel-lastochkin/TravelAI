from __future__ import annotations

from typing import Dict, List, Optional

from pydantic import BaseModel, Field


class PlaceRecognitionResult(BaseModel):
    placeName: str
    city: str
    country: str
    confidence: int = Field(ge=0, le=100)
    quickFacts: List[str]
    story: str


class PlaceDetailContent(BaseModel):
    history: str
    visitInfo: str


class NearbyPlaceItem(BaseModel):
    name: str
    distanceHint: str
    whyVisit: str


class NearbyPlacesResult(BaseModel):
    places: List[NearbyPlaceItem]


class PlaceContext(BaseModel):
    placeName: str
    city: str
    country: str
    quickFacts: List[str] = Field(default_factory=list)
    story: str = ""
    language: str = "English"
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class HealthResponse(BaseModel):
    status: str
    service: str
    environment: str
    promptVersions: Dict[str, str]