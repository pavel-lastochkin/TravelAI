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

---

## Data Model

### PlaceRecognitionResult

* placeName: String
* city: String
* country: String
* confidence: Int (0–100)
* description: String
* interestingFact: String

This is the single source of truth for AI output.

---

## Services

### GeminiService

* Handles all communication with Gemini API
* Input: image or text
* Output: PlaceRecognitionResult (preferred) or legacy string (deprecated)

---

## UI Structure

### ExplorePlaceView

Main screen:

* Image picker (camera + gallery)
* Analyze button
* Result display

### Result UI

* Image (top)
* Structured card view (PlaceRecognitionResultView)
* Loading + error states

---

## Design Principles

* Single responsibility per screen
* AI logic separated from UI
* Structured data preferred over raw text
* Photo analysis is the primary feature

---

## Future Extensions

* Apple Maps integration
* Nearby places
* Save / favorites
* History of scanned places

---

## Important Rules

* Do NOT change data model without updating UI
* Do NOT return raw text from AI layer (except legacy fallback)
* All AI responses should be parsed into structured models when possible

