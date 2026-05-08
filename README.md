# UserManagerSwiftUI

A SwiftUI technical exercise that demonstrates a **clean MVVM + Coordinator-style navigation** stack for managing users: load from a public REST API, persist locally with Realm, support edits and logical deletes, and optionally read the device location when creating a profile.

## Features

- **User list** with pull-to-refresh, non-destructive error surfacing, swipe-to-delete with confirmation, and empty / loading / error states.
- **User detail** with a compact card layout and navigation to **edit** name and email with inline validation.
- **Create user** flow shell with **Core Location** (when-in-use permission, one-shot fix, loading overlay, coordinate alert).
- **Offline-friendly reads**: on fetch failure, previously persisted users can still be shown when available.
- **Logical delete** with tombstone IDs stored in Realm so removed users do not reappear after refresh.
- **Localization**: English and Spanish via `Localizable.strings` (plus Spanish `InfoPlist.strings` for the location usage string).

## Architecture

| Layer | Role |
|--------|------|
| **Presentation** | SwiftUI screens, lightweight view models (`ObservableObject` / `@Published`, `@Observable` for location), shared layout helpers (`AppMetrics`), string keys via `L10n`. |
| **Domain** | `User` model and `UserRepository` protocol. |
| **Data** | `UserRepositoryImpl` orchestrates **Alamofire** networking and **Realm** persistence; DTO mapping (`UserDTO` → `User`). |
| **Core** | Location abstractions (`LocationManager`, `CoreLocationManager`), form validation. |
| **App** | Composition root in `UserManagerSwiftUIApp`, `AppCoordinator` navigation stack, `UsersChangeNotifier` for cross-screen refresh signals. |

Business rules (validation, delete filtering, API mapping) stay **out of views**; screens depend on protocols and injected services where practical.

## Technologies

- SwiftUI, Swift Concurrency (`async`/`await`)
- Alamofire (HTTP + validation)
- RealmSwift (local persistence)
- Core Location (when-in-use, `CLLocationManagerDelegate`)

## Requirements

- Xcode 17+ (project targets **iOS 26.4**)
- Swift 5 with default actor isolation configured for this target (network boundary uses explicit `nonisolated` where needed)

## Setup

1. Clone the repository.
2. Open `UserManagerSwiftUI.xcodeproj` in Xcode.
3. Resolve Swift packages (Alamofire, Realm) if prompted.
4. Select the **UserManagerSwiftUI** scheme and run on a simulator or device.

No custom backend or API keys are required.

## Folder structure (high level)

```
UserManagerSwiftUI/
├── App/                    # App entry, coordinator, change notifications
├── Core/                   # Location, validation
├── Data/                   # Network, DTOs, Realm, repository implementation
├── Domain/                 # Models, repository protocol
├── Presentation/
│   ├── Components/
│   ├── Screens/
│   └── ViewModels/
├── Resources/              # en.lproj / es.lproj — Localizable.strings, InfoPlist.strings
└── Support/                # AppMetrics, L10n
```

## API

- **Base URL**: `https://jsonplaceholder.typicode.com`
- **Endpoint used**: `GET /users` (see `APIEndpoint` and `APIEndpoint.makeURL()`).

Responses are decoded as `UserDTO` and mapped to domain `User` (including address/geo latitude and longitude as `Double`).

## Persistence

- **Realm** stores the latest successful user list for fast display and offline fallback.
- **Logical deletes**: deleted user IDs are recorded so merged server data does not resurrect deleted rows on this device.
- Realm file configuration and helpers live under `Data/Persistence/`.

## Localization

- **UI strings**: `Resources/en.lproj/Localizable.strings` and `Resources/es.lproj/Localizable.strings`.
- **Code**: `L10n` provides typed accessors; format strings use `String(format:String(localized:), …)` where placeholders are needed.
- **Location permission**: `NSLocationWhenInUseUsageDescription` is set in build settings for the default (English) string; **Spanish** overrides live in `Resources/es.lproj/InfoPlist.strings`.
- Xcode **known regions** include `en` and `es` (`developmentRegion` is English).

To preview Spanish in Simulator: **Settings → General → Language & Region** (or scheme **App Language** / **Region** in Xcode run options).

## Future improvements

- Complete **create user** with form fields and `POST /users` against the same API contract.
- Richer **synchronization** strategy (timestamps, conflict resolution) if the backend becomes real.
- **Image / avatar** support and richer user fields if the API evolves.
- **Unit tests** for validation, DTO mapping, and repository edge cases; UI tests for critical flows.
- **Swift Testing** migration for new tests alongside XCTest.

## License

Private / evaluation use unless otherwise specified.
