# Travel AI — Architecture Overview

## App Purpose

Travel AI is an iOS application that identifies places from photos and provides structured travel information using AI (Gemini).

---

## Core Flow

### Photo Analysis Flow (Primary)

1. User selects or takes a photo
2. Image is sent to Gemini Vision API
3. Gemini returns structured JSON
4. JSON is decoded into `PlaceRecognitionResult`
5. UI renders a structured result card
6. App prefetches `PlaceDetailContent` (history + visit info) in the background
7. User chooses a fixed action:
   * Learn the history
   * How to visit
   * See nearby
8. Nearby content is requested on demand via `NearbyPlacesResult`

---

## Data Model

### PlaceRecognitionResult

* placeName: String
* city: String
* country: String
* confidence: Int (0–100)
* quickFacts: [String] — exactly three short traveler-friendly facts
* story: String — local-guide narrative (60–80 words; concrete, no brochure tone)

Decoder accepts legacy `description`, `interestingFact`, and combined `location` fields.

This is the source of truth for the first AI response.

### PlaceDetailContent

* history: String
* visitInfo: String

Prefetched after the first recognition succeeds.

### NearbyPlacesResult

* places: [NearbyPlaceItem]
  * name: String
  * distanceHint: String
  * whyVisit: String

Requested only when the user opens "See nearby".

---

## Services

### GeminiService

* Handles all communication with Gemini API
* `analyzePlace` → `PlaceRecognitionResult`
* `fetchPlaceDetails` → `PlaceDetailContent`
* `fetchNearbyPlaces` → `NearbyPlacesResult`

Prompts are centralized in `PromptBuilder`.

---

## UI Structure

### ExplorePlaceView

Main screen:

* Image picker (camera + gallery)
* Analyze button
* Result display
* Fixed continuation actions

### Result UI

* Image (top)
* Structured card view (`ResultCardView`)
* Fixed actions (`PlaceExploreActionsView`)
* Loading + error states

---

## Design Principles

* Single responsibility per screen
* AI logic separated from UI
* Structured data preferred over raw text
* Photo analysis is the primary feature
* App-owned actions instead of free-form chat

---

## Future Extensions

* Apple Maps integration for nearby places
* Fresh hours / tickets data source
* Save / favorites
* History of scanned places

---

## Important Rules

* Do NOT change data model without updating UI
* Do NOT return raw text from AI layer (except legacy fallback)
* All AI responses should be parsed into structured models when possible
