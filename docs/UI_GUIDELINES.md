
# Travel AI — UI Guidelines

## General Style

The app should follow native iOS design principles.

---

## Layout Rules

* Always use ScrollView for result screens
* Use vertical stacking layout
* Avoid dense or developer-style UI

---

## Photo Display

* Image is always top element
* Rounded corners (12–16px)
* Full width with padding

---

## Result Display

Use structured cards:

* Place Name (large, bold)
* Location (secondary text)
* Confidence (small badge)
* Description (body text)
* Interesting Fact (highlighted section)

---

## Loading States

* Use ProgressView
* Show descriptive text:

  * "Analyzing photo..."
  * "Detecting landmark..."

---

## Error States

* Never show raw API errors
* Always show user-friendly messages

---

## Visual Style

* Use system colors only
* Avoid custom gradients
* Use SF Symbols for icons
* Keep spacing generous

---

## UX Principle

One screen = one clear purpose:
Photo → Result
