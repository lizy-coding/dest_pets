# AGENTS.md - desktop_pet

Instructions for AI agents working on this project. Keep changes aligned with the current v0.1 architecture and the evolution plan in `EVOLUTION_PLAN.md`.

---

## Overview

**desktop_pet** is a Flutter macOS desktop pet PoC. It renders a transparent, borderless, always-on-top desktop mascot, plays a Codex atlas animation, supports drag-to-move, can switch local pet resources, and persists current-version user config.

- **Current release**: `v0.1.0` internal macOS alpha
- **Tech stack**: Flutter (Dart SDK ^3.11.5), Material 3, `window_manager`, `screen_retriever`, `shared_preferences`, `provider`
- **Primary platform**: macOS
- **Lint**: `flutter_lints` ^6.0.0

---

## Current Project Structure

```text
lib/
├── main.dart
├── app/
│   └── app.dart
├── desktop/
│   ├── desktop_window_controller.dart
│   └── macos_window_bootstrap.dart
├── pet/
│   ├── animation/
│   │   ├── pet_animation_controller.dart
│   │   └── pet_atlas.dart
│   ├── controller/
│   │   └── pet_controller.dart
│   ├── model/
│   │   ├── pet_animation_state.dart
│   │   ├── pet_config.dart
│   │   ├── pet_runtime_mode.dart
│   │   └── pet_state.dart
│   └── view/
│       ├── pet_actor.dart
│       ├── pet_hit_area.dart
│       └── pet_view.dart
├── resources/
│   ├── data/
│   │   └── pet_resource_repository.dart
│   └── model/
│       ├── pet_animation_manifest.dart
│       ├── pet_manifest.dart
│       └── pet_resource.dart
└── settings/
    └── settings_store.dart

assets/pets/default_pet/
├── pet.json
└── spritesheet.webp
```

Do not use older names from pre-v0.1 code. In particular, do not recreate `PetPackage`, `PetAppearance*`, `PetScene`, or `PetSettings`.

---

## Commands

| Task | Command |
| --- | --- |
| Run macOS | `flutter run -d macos` |
| Analyze/lint | `flutter analyze` |
| Test | `flutter test` |
| Debug build | `flutter build macos --debug` |
| Release build | `flutter build macos --release` |
| Get deps | `flutter pub get` |
| Upgrade deps | `flutter pub upgrade --major-versions` |

Before release-oriented changes, run:

```sh
dart format lib test
flutter analyze
flutter test
flutter build macos --release
```

---

## Architecture Rules

- **Single app root**: `lib/app/app.dart` owns app-level providers and creates `PetController`.
- **Single runtime entry point**: `PetController` is the only UI-facing controller for pet behavior. UI reads `controller.state` and calls controller methods.
- **State machine first**: Runtime mode belongs in `PetRuntimeMode`; do not encode mode using nullable resources, ad hoc booleans, or UI-local flags.
- **Config model**: Persistable user config belongs in `PetConfig`.
- **Runtime state model**: Render/runtime state belongs in `PetState`.
- **Resource model**: Resource parsing and validation belongs under `lib/resources/`.
- **Settings model**: SharedPreferences access belongs only in `SettingsStore`.
- **Window boundary**: Native window calls belong only in `DesktopWindowController` and `MacosWindowBootstrap`.
- **Renderer boundary**: `PetActor` renders a `PetResource` plus `PetAnimationState`; it must not know about settings, repositories, or controller methods.

Dependency flow should stay:

```text
main.dart
  -> SettingsStore
  -> DesktopWindowController
  -> App
       -> PetResourceRepository
       -> PetController
       -> PetView
            -> PetHitArea
            -> PetActor
```

---

## Do Not Reintroduce

These were deliberately removed during the v0.1 normalization:

- `lib/pet/pet_package.dart`
- `lib/pet/pet_package_repository.dart`
- `lib/pet/model/pet_appearance_*`
- `lib/pet/data/pet_settings_store.dart`
- `lib/settings/pet_settings.dart`
- Old SharedPreferences keys such as `desktop_pet.pet.*`, `desktop_pet.window.*`, or `desktop_pet.appearance.*`
- Old manifest fields such as `displayName` or `spritesheetPath`
- Loose `idle_*.png` frame assets
- UI-driven resource fallback logic
- Direct `SharedPreferences` calls outside `SettingsStore`

If a migration is needed in the future, implement it as an explicit versioned migration plan. Do not silently add compatibility to core models.

---

## Resource Contract

Bundled resources use:

```text
assets/pets/default_pet/
├── pet.json
└── spritesheet.webp
```

Local resources use:

```text
${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/
├── pet.json
└── spritesheet.webp
```

Manifest fields are strict:

```json
{
  "id": "default_pet",
  "name": "Default Pet",
  "description": "Default desktop pet.",
  "defaultScale": 1.0,
  "atlas": {
    "image": "spritesheet.webp",
    "columns": 8,
    "rows": 9,
    "frameWidth": 192,
    "frameHeight": 208
  },
  "animations": {
    "idle": {
      "row": 0,
      "frames": [0, 1, 2, 3, 4, 5],
      "durationsMs": [280, 110, 110, 140, 140, 320],
      "loop": true
    }
  }
}
```

Repository behavior:

- `PetResourceRepository.loadAvailableResources()` returns only valid resources.
- The bundled resource is required; invalid bundled manifests should fail initialization.
- Invalid local resources are ignored.
- Unsafe relative paths, missing spritesheets, missing atlas data, and missing `idle` animation are invalid.

---

## Persistence

Use only these current-version keys through `SettingsStore`:

```text
desktop_pet.config.petId
desktop_pet.config.scale
desktop_pet.config.window.x
desktop_pet.config.window.y
desktop_pet.config.alwaysOnTop
```

Rules:

- UI and repositories must not call `SharedPreferences` directly.
- Window position is part of `PetConfig`.
- Scale clamping belongs in `PetController`.
- Config operations are async and must be awaited.

---

## UI Rules

- All app/window backgrounds remain `Colors.transparent`.
- Keep the pet surface stable at the desktop-window size unless deliberately changing window behavior.
- Use `RepaintBoundary` around the pet render area.
- Use `HitTestBehavior.translucent` for transparent hit areas.
- Right-click / secondary tap opens the lightweight pet menu.
- The right-click menu is a known v0.1 weakness. If you improve it, preserve resource switching and size controls, and add tests for dismissal behavior.
- Do not add a full settings page unless it is part of a planned milestone in `EVOLUTION_PLAN.md`.

---

## Testing

- Tests live in `test/`.
- File naming: `<feature>_test.dart`.
- Widget tests use `tester.pumpWidget()` followed by `tester.pump()` or `tester.pumpAndSettle()` as appropriate.
- Mock or guard native window behavior so tests do not trigger real desktop window side effects.
- Always dispose controllers in tests.

Coverage expectations:

- Manifest parser changes need model tests.
- Repository discovery changes need local valid/invalid resource tests.
- Settings key changes need `SettingsStore` tests.
- Runtime mode changes need `PetController` tests.
- Menu or interaction changes need widget tests.

---

## Release Files

Keep these files synchronized for release work:

- `pubspec.yaml`
- `CHANGELOG.md`
- `RELEASE.md`
- `README.md`
- `macos/Runner/Configs/AppInfo.xcconfig`

The current unsigned artifact path is:

```text
build/macos/Build/Products/Release/Desktop Pet.app
```

---

## Adding A New Feature

1. Read `EVOLUTION_PLAN.md` and confirm the feature fits the next milestone.
2. Prefer existing modules before creating a new domain.
3. Route config through `PetConfig` and `SettingsStore`.
4. Route runtime behavior through `PetController`.
5. Route resource changes through `PetResourceRepository` and manifest models.
6. Add focused tests at the same layer where behavior changed.
7. Run `dart format lib test`, `flutter analyze`, and `flutter test`.
