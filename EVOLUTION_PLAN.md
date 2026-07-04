# Evolution Plan

This file records the intended direction after the `v0.1.0` internal macOS alpha. Use it to keep future agent work aligned with the current architecture instead of reintroducing removed compatibility layers or ad hoc UI logic.

## Product Baseline

`v0.1.0` is the first usable macOS alpha:

- Bundled default pet renders in a transparent borderless window.
- Window is draggable and always on top.
- Window position persists across restarts.
- Pet scale persists across restarts.
- Local resources are discovered from `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/`.
- Runtime is controlled by `PetController` and `PetState`.
- Resources use the normalized manifest shape.

Known v0.1.0 issue:

- Right-click menu is visually rough and does not reliably close when clicking outside it in the transparent desktop window.

## Direction

The project should evolve as a small, stable desktop utility:

- Keep the pet lightweight and unobtrusive.
- Prefer deterministic local resource loading over network features.
- Keep rendering driven by manifests, not hardcoded asset assumptions.
- Keep UI as a thin layer over controller state.
- Expand behavior through state machine and manifest additions rather than one-off widget state.

## Milestones

### v0.1.1 - Menu And Interaction Polish

Goal: make the existing alpha easier to use without expanding scope.

Tasks:

- Replace or repair the right-click menu so outside-click dismissal works reliably.
- Improve menu layout while keeping it usable inside/near the 200x200 transparent window.
- Add an explicit Quit action if it can be done without adding a tray/menu-bar system.
- Add widget coverage for menu dismissal and command dispatch.

Exit criteria:

- Manual smoke test confirms menu can open, choose an item, and close by outside click.
- `flutter analyze`, `flutter test`, and `flutter build macos --release` pass.

### v0.2.0 - Settings Surface

Goal: expose current config in a maintainable UI.

Tasks:

- Add UI for `alwaysOnTop`.
- Add reset config action.
- Add visible error state and recovery action.
- Add resource refresh action.
- Keep all persistence routed through `SettingsStore`.

Exit criteria:

- No direct `SharedPreferences` calls outside `SettingsStore`.
- Settings UI reads only `PetController.state` and dispatches controller methods.
- Controller tests cover new config paths.

### v0.3.0 - Resource Management

Goal: make local pet resources easier to validate and manage.

Tasks:

- Add resource validation reporting for invalid local packages.
- Add local resource preview metadata in the menu/settings UI.
- Consider zip/import only after validation reporting exists.
- Keep manifest parsing strict unless a versioned migration is explicitly planned.

Exit criteria:

- Invalid resources never break startup.
- Users can understand why a local resource was ignored.
- Repository tests cover validation cases.

### v0.4.0 - Animation Behavior Expansion

Goal: support additional pet behavior without changing render contracts.

Tasks:

- Add controller-level transitions for `walk`, `sleep`, `clicked`, or similar states.
- Extend `PetAnimationState` through `animationId`; do not hardcode animation rows in UI.
- Add manifest-level validation for any new required animation behavior.

Exit criteria:

- `PetActor` remains controller-agnostic.
- UI does not branch on atlas rows or frame durations.
- Controller tests cover state transitions.

### v1.0.0 - Distributable macOS App

Goal: prepare a real end-user macOS release.

Tasks:

- Add app icon.
- Configure signing.
- Configure notarization.
- Decide artifact packaging format.
- Review bundle identifier and copyright.
- Add release checklist for signed artifacts.

Exit criteria:

- Release artifact is signed and notarized.
- Installation/opening behavior is verified on a clean macOS account.
- README includes user-facing install and troubleshooting notes.

## Architectural Guardrails

Do:

- Put persistent config in `PetConfig`.
- Put runtime state in `PetState`.
- Put resource parsing in `resources/model`.
- Put resource discovery in `PetResourceRepository`.
- Put SharedPreferences access in `SettingsStore`.
- Put native window operations in `DesktopWindowController` and `MacosWindowBootstrap`.
- Put UI rendering in `pet/view`.

Do not:

- Recreate `PetPackage` or `PetPackageRepository`.
- Recreate `PetAppearanceController`, `PetAppearanceState`, or `PetSettingsStore`.
- Recreate `PetSettings`.
- Add direct SharedPreferences calls in UI, controller, or resource code.
- Add compatibility for old manifest fields unless there is a written migration milestone.
- Hardcode atlas frame data in UI.
- Add large settings surfaces before fixing v0.1.1 menu behavior.

## Release Checklist

For every tagged release:

```sh
dart format lib test
flutter analyze
flutter test
flutter build macos --release
```

Then update:

- `pubspec.yaml`
- `CHANGELOG.md`
- `RELEASE.md`
- `README.md` if behavior or install steps changed
- `macos/Runner/Configs/AppInfo.xcconfig` if app identity changed

Create a git tag matching the release, for example:

```sh
git tag v0.1.1
```
