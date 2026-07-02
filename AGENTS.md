# AGENTS.md — desktop_pet

Instructions for AI agents working on this project. Follow these conventions to stay consistent with the existing codebase.

---

## Overview

**desktop_pet** is a Flutter cross-platform desktop pet (desktop mascot) PoC. Current focus: macOS transparent borderless window with frame-animated PNG character. The pet floats on top of all windows, is draggable, and remembers its last screen position.

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
│   ├── pet_scene.dart                  Scene: Scaffold + layout
│   ├── pet_actor.dart                  Frame-animated pet renderer
│   ├── pet_animation_controller.dart   AnimationController wrapper
│   └── pet_hit_area.dart               Drag-to-move GestureDetector
└── settings/
    └── pet_settings.dart               Position persistence (SharedPreferences)

assets/pets/default/
├── idle_0.png  through  idle_3.png     Idle animation frames

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

- **No comments** unless strictly necessary. Code should be self-documenting.
- Use `final` over `var`/`const` for local variables when possible.
- All imports use relative paths (package-style imports are not used in lib/).
- File names: `snake_case.dart`. Class names: `PascalCase`.
- Follow `flutter_lints` rules. Run `flutter analyze` before committing.

### Architecture

- **Dependency injection via constructor pass-through** — no DI framework. Controllers are created in `main()` and passed down the widget tree manually.
- **Stateless scene composition** — `PetScene` is `StatelessWidget`; all mutable state lives in child widgets (`PetActor`, `PetHitArea`).
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

- `PetAnimationController` wraps Flutter's `AnimationController`. Always use this wrapper for pet animations — not `AnimationController` directly.
- Frame count is injected at construction. Frame indices are computed as `(value * frameCount).floor().clamp(0, frameCount - 1)`.
- Use `AnimatedBuilder` listening to `_animation.listenable` for frame-driven rebuilds.
- Animation state lifecycle: `initState` creates + starts, `didUpdateWidget` recreates if frame count changes, `dispose` cleans up.

### Assets

- Pet animation frames live under `assets/pets/<pet_name>/` with naming convention `<animation_name>_<frame_index>.png`.
- Declare new asset directories in `pubspec.yaml` under the `flutter.assets` section.
- Use directory-level asset declarations (e.g., `assets/pets/default/`) rather than individual file declarations.

### Persistence

- Use `PetSettings` for window position. Do not call `SharedPreferences` directly.
- Key naming convention: `desktop_pet.<domain>.<key>` (e.g., `desktop_pet.window.x`).
- Operations are async; callers must `await`.

### UI

- All backgrounds must be `Colors.transparent` (scaffold, canvas, colored boxes).
- Use `RepaintBoundary` around the pet area to optimize rendering.
- `HitTestBehavior.translucent` for gesture detection areas (the pet is transparent so opaque hit tests won't fire).

---

## Testing

- Tests live in `test/`. File naming: `<feature>_test.dart`.
- Widget tests use `tester.pumpWidget()` followed by `tester.pump()` for the first frame.
- Mock `DesktopWindowController` or disable native control guards for test environments (the current test creates a real controller but `supportsNativeWindowControl` returns false during non-desktop test runs).
- Always `dispose()` controllers after tests to avoid resource leaks.

---

## Adding a New Feature

1. Create a new directory under `lib/<feature>/`.
2. If the feature needs a new dependency, add it to `pubspec.yaml` and run `flutter pub get`.
3. If the feature adds assets, declare the directory in `pubspec.yaml` under `flutter.assets`.
4. Wire the feature into the widget tree from `PetScene` or `main.dart`.
5. Write a widget test in `test/`.
6. Run `flutter analyze` and `flutter test` to verify.
