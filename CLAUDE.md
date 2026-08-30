# CLAUDE.md

## Repository overview

- macOS app built with SwiftUI
- Swift 6
- Minimum deployment target is macOS 14.6
- Single storage implementation: `PatientDataStore` persists patient data to JSON in Application Support
- No Core Data path remains in the current project state

## Important files

- `Audiometry/AudiometryApp.swift` — app entry point
- `Audiometry/Views/ContentView.swift` — main form and calculation UI
- `Audiometry/Model/PatientNavigationView.swift` — SwiftUI navigation view for patient actions, search, print, and language menu
- `Audiometry/Model/PatientDataStore.swift` — persistence and sample-data bootstrap
- `Audiometry/Model/PatientData.swift` — persisted patient model
- `Audiometry/Model/AudiometryCalculations.swift` — hearing-loss, SAL, and ELI logic
- `Audiometry/<language>.lproj/Localizable.strings` — localized UI strings

## Working rules for agents

- Keep changes small and targeted
- Prefer updating existing SwiftUI views and models instead of introducing new architecture
- Preserve the single-store flow centered on `PatientDataStore.shared`
- When changing user-visible text, update all localization files instead of hardcoding strings
- Keep macOS-only behavior intact; this is not a cross-platform target

## Validation

- Build with:
  - `xcodebuild -project Audiometry.xcodeproj -scheme Audiometry -destination 'platform=macOS' build`
- There is no separate test target in the repository at the moment

## Persistence details

- Saved patients live at:
  - `~/Library/Containers/perez987.Audiometry/Data/Library/Application Support/Audiometry/patients.json`
- The bundled sample file is copied on first run when no saved file exists
