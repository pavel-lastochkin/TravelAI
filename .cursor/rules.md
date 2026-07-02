
# Cursor Development Rules — Travel AI

## CONTEXT FIRST (MANDATORY)

Before making any changes:

1. Read `/docs/ARCHITECTURE.md`
2. Read `/docs/AI_GUIDELINES.md`
3. Read `/docs/UI_GUIDELINES.md`

Do not proceed until you understand the architecture.

---

## PRIMARY GOAL

We are building an iOS app called **Travel AI**.

Core feature:

* Photo → AI analysis → structured place result

This is the ONLY priority unless explicitly stated otherwise.

---

## STRICT RULES

### 1. Do not break architecture

* Do not change data models without reason
* Do not introduce new AI formats
* Always use PlaceRecognitionResult as source of truth

---

### 2. Scope control

When modifying code:

* Touch ONLY files explicitly related to the task
* Do NOT refactor unrelated modules
* Do NOT “improve architecture” unless asked

---

### 3. AI behavior

* Gemini must always return structured JSON
* No free-text AI responses in production flow
* Follow AI_GUIDELINES.md strictly

---

### 4. UI rules

* Follow UI_GUIDELINES.md
* Use SwiftUI best practices
* Always prefer ScrollView for result screens
* Keep UI clean and production-like

---

### 5. Output discipline

When making changes:

* Prefer minimal diffs
* Avoid rewriting whole files
* Focus only on requested feature

---

## PERFORMANCE RULES

To reduce token usage:

* Do not re-read entire project unless needed
* Use existing /docs as primary context
* Avoid redundant refactoring

---

## THINKING MODE

Before coding:

* Identify affected files
* Identify required data flow
* Confirm output model

Only then implement.

---

## HARD CONSTRAINT

If request conflicts with /docs:
→ docs win

Always follow documentation over user prompt if inconsistent.

---
