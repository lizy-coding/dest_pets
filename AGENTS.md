# AGENTS.md — desktop_pet

Instructions for AI agents working on this project. Follow these conventions to stay consistent with the existing codebase.

---

## Overview

**desktop_pet** is a Flutter cross-platform desktop pet (desktop mascot) PoC. Current focus: macOS transparent borderless window with a Codex pet package atlas. The pet floats on top of all windows, is draggable, can switch local custom pet packages, and remembers its last screen position.

- **Tech stack**: Flutter (Dart SDK ^3.11.5), Material 3, `window_manager`, `screen_retriever`, `shared_preferences`
- **Primary platform**: macOS (Android/iOS directories exist for future expansion)
- **Lint**: `flutter_lints` ^6.0.0 (config in `analysis_options.yaml`)

---

## Project Structure

```
lib/
├── main.dart                     Entry: init settings → window → runApp
├── app/
│   └── pet_app.dart              MaterialApp root with transparent theme
├── desktop/
│   ├── desktop_window_controller.dart   Cross-platform window abstraction
│   └── macos_window_bootstrap.dart      macOS-specific window setup
├── pet/
│   ├── pet_scene.dart                  Scene: Scaffold + layout + pet picker
│   ├── pet_actor.dart                  Atlas-animated pet renderer
│   ├── pet_animation_controller.dart   Variable-duration frame controller
│   ├── pet_atlas.dart                  Codex pet atlas constants
│   ├── pet_package.dart                Pet package model
│   ├── pet_package_repository.dart     Bundled/local pet discovery
│   └── pet_hit_area.dart               Drag-to-move GestureDetector
└── settings/
    └── pet_settings.dart               Position + pet selection persistence

assets/pets/default/
├── pet.json                            Bundled default manifest
└── spritesheet.webp                    Bundled default atlas

test/
└── widget_test.dart                    Widget-level render test
```

---

## Commands

| Task         | Command                      |
|--------------|------------------------------|
| Run (macOS)  | `flutter run -d macos`       |
| Analyze/lint | `flutter analyze`            |
| Test         | `flutter test`               |
| Build macOS  | `flutter build macos`        |
| Get deps     | `flutter pub get`            |
| Upgrade deps | `flutter pub upgrade --major-versions` |

---

## Code Conventions

### General

- Avoid comments unless they explain non-obvious behavior, platform constraints, or deliberate error tolerance.
- Use `final` over `var`/`const` for local variables when possible.
- Use relative imports inside `lib/`. Tests may use package imports.
- File names: `snake_case.dart`. Class names: `PascalCase`.
- Follow `flutter_lints` rules. Run `flutter analyze` before committing.

### Architecture

- **Dependency injection via constructor pass-through** — no DI framework. Controllers are created in `main()` and passed down the widget tree manually.
- **Scene-owned pet selection** — `PetScene` owns current pet package state and persists selection through `PetSettings`.
- **Platform abstraction** — `DesktopWindowController` is the single entry point for window operations. Platform-specific code (e.g., `MacosWindowBootstrap`) is called only when `Platform.isMacOS` is true.
- **Guard native calls** — always check `supportsNativeWindowControl` before calling `window_manager` methods. This ensures the code doesn't crash on web or mobile:
  ```dart
  bool get supportsNativeWindowControl =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  ```

### Window Management

- All window configuration goes through `desktop/desktop_window_controller.dart`.
- macOS-specific window options (size, always-on-top, title bar, shadow, workspaces) belong in `macos_window_bootstrap.dart`.
- Window position is persisted via `PetSettings` with a **250ms debounce** to avoid excessive writes during drag operations.

### Animation

- `PetAnimationController` owns pet frame timing. Use it for pet animations instead of open-coded timers or `AnimationController` instances.
- Frame durations come from the Codex pet atlas contract. The idle row uses `280, 110, 110, 140, 140, 320 ms`.
- Use `AnimatedBuilder` listening to `_animation.listenable` for frame-driven rebuilds.
- Animation state lifecycle: `initState` creates + starts, `didUpdateWidget` recreates when the selected pet changes, `dispose` cleans up.

### Assets

- Bundled pet assets use the Codex pet package shape: `pet.json` plus `spritesheet.webp`.
- The atlas is `1536x1872`, 8 columns x 9 rows, with `192x208` cells.
- Local custom pets are discovered from `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/`.
- Declare bundled asset directories in `pubspec.yaml` under `flutter.assets`; keep directory-level declarations such as `assets/pets/default/`.
- Do not reintroduce loose `idle_*.png` frame assets unless the rendering model is deliberately changed back.

### Persistence

- Use `PetSettings` for window position. Do not call `SharedPreferences` directly.
- Use `PetSettings` for selected pet persistence. Do not call `SharedPreferences` directly from UI or pet package code.
- Key naming convention: `desktop_pet.<domain>.<key>` (e.g., `desktop_pet.window.x`).
- Operations are async; callers must `await`.

### UI

- All backgrounds must be `Colors.transparent` (scaffold, canvas, colored boxes).
- Use `RepaintBoundary` around the pet area to optimize rendering.
- `HitTestBehavior.translucent` for gesture detection areas (the pet is transparent so opaque hit tests won't fire).
- Right-click / secondary tap opens the pet package picker. Keep this lightweight and usable inside a 200x200 transparent window.

---

## Testing

- Tests live in `test/`. File naming: `<feature>_test.dart`.
- Widget tests use `tester.pumpWidget()` followed by `tester.pump()` for the first frame.
- Mock or guard native window behavior so tests do not trigger real desktop window side effects.
- Always `dispose()` controllers after tests to avoid resource leaks.

---

## Adding a New Feature

1. Prefer existing modules first; create `lib/<feature>/` only for a genuinely new domain.
2. If the feature needs a new dependency, add it to `pubspec.yaml` and run `flutter pub get`.
3. If the feature adds bundled assets, declare the directory in `pubspec.yaml` under `flutter.assets`.
4. Wire the feature into the widget tree from `PetScene` or `main.dart`.
5. Write a widget test in `test/`.
6. Run `flutter analyze` and `flutter test` to verify.
