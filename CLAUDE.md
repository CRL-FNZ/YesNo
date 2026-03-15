# YesNo - Quiz Game for iOS

## Project Overview
A SwiftUI-based Yes/No quiz game where players tilt their phone (gyroscope) to answer true/false questions. Supports multiple teams, timed and points-based modes, and Italian/German localization.

## Tech Stack
- **Language:** Swift
- **UI Framework:** SwiftUI
- **Sensors:** CoreMotion (gyroscope via CMMotionManager)
- **Target:** iOS
- **Min iOS version:** 17+ (uses new `onChange(of:)` API with old/new value)

## Project Structure
```
YesNo/YesNo/
├── YesNoApp.swift          # App entry point, view routing
├── Models.swift            # GameState, Question, Category, Language, GameMode
├── MotionManager.swift     # Gyroscope wrapper (CMMotionManager)
├── LanguageSelectionView.swift  # Language picker (IT/DE)
├── HomeView.swift          # Start screen
├── GameSetupView.swift     # Categories, mode, teams config
├── GameView.swift          # Main gameplay with tilt controls
├── ResultView.swift        # Final scores
├── questions.json          # Italian questions
└── questions_de.json       # German questions
```

## Key Conventions
- Questions are stored in JSON files, not hardcoded
- All user-facing strings are localized via `Language` extension properties in Models.swift
- Category raw values (`culturaGenerale`, `scienzaNatura`, `popCulture`, `storia`) must match between Swift enum and JSON files
- Navigation uses a `ViewType` enum with `@State`/`@Binding`, no NavigationStack
- `GameState` is an `ObservableObject` shared across views via `@ObservedObject`

## Adding Questions
Add entries to `questions.json` (Italian) and `questions_de.json` (German) with this format:
```json
{ "text": "Question text?", "answer": true, "category": "culturaGenerale" }
```
Valid categories: `culturaGenerale`, `scienzaNatura`, `popCulture`, `storia`

## Build
Open `YesNo/YesNo.xcodeproj` in Xcode and build for iOS simulator or device.
