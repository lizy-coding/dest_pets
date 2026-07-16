# Windows Internal Alpha Release Checklist

This checklist is the final release gate for the unsigned Windows internal
alpha. Complete it on a Windows host against one clean source revision and the
exact zip that will be distributed. Do not create or push the version tag until
every required item is marked `PASS`.

## Candidate Identity

```text
Version: 0.6.0+6
Release commit:
Windows edition and version:
Architecture: x64
Flutter version:
Dart version:
Visual Studio version:
Tester:
Test date:
```

The release commit must be clean and contain the synchronized version,
changelog, release notes, README files, Windows runner metadata, icon, and
packaging script.

## Automated Build Gate

Run from a clean checkout in a Developer Command Prompt or terminal configured
for Flutter Windows desktop development.

| Result | Command | Evidence |
| --- | --- | --- |
| PENDING | `flutter doctor -v` | Record supported Windows and Visual Studio toolchain. |
| PENDING | `flutter pub get` | Record successful dependency resolution. |
| PENDING | `dart format --output=none --set-exit-if-changed lib test` | Must report zero changed files. |
| PENDING | `flutter analyze` | Must report no issues. |
| PENDING | `flutter test` | All tests must pass. |
| PENDING | `scripts\package_windows.bat` | Must complete all four steps with exit code 0. |

Required outputs:

```text
dist/Desktop Pet-0.6.0-windows-x64.zip
dist/Desktop Pet-0.6.0-windows-x64.zip.sha256
```

## Artifact Gate

| Result | Check | Evidence |
| --- | --- | --- |
| PENDING | Verify the SHA-256 file with `Get-FileHash`. | Record actual hash below. |
| PENDING | Windows Defender scan reports no detected threat. | Record Defender result. |
| PENDING | Extract the zip to a new directory; do not run inside the archive. | Record extraction path. |
| PENDING | `DesktopPet.exe`, `flutter_windows.dll`, the three required plugin DLLs, `data\icudtl.dat`, `data\app.so`, and `data\flutter_assets` exist. | Record inspected bundle. |
| PENDING | Bundled `default_pet` manifest and spritesheet exist under Flutter assets. | Record inspected paths. |
| PENDING | A second Windows account or machine launches the extracted artifact. | Record environment. |

```text
ZIP size:
SHA-256:
Second-account or second-machine environment:
```

## Runtime Smoke Gate

| Result | Scenario | Expected result |
| --- | --- | --- |
| PENDING | First launch | Pet appears without a console window, opaque background, or startup error. |
| PENDING | Window appearance | Main surface is transparent, frameless, fixed at 200x200, and absent from the taskbar. |
| PENDING | Always on top | Enabled by default and menu toggle takes effect. |
| PENDING | Drag and restart | Pet moves with drag and restores its persisted position after restart. |
| PENDING | Right-click menu | Menu opens at the cursor and all enabled actions complete. |
| PENDING | Menu dismissal | Clicking another window closes the auxiliary menu on blur. |
| PENDING | Scale and reset | Increase, decrease, reset scale, and reset config behave and persist correctly. |
| PENDING | Bundled/local switch | Switch between bundled and valid local pets, refresh, and switch back. |
| PENDING | Default local path | `%USERPROFILE%\.codex\pets` resources are discovered. |
| PENDING | `CODEX_HOME` override | `%CODEX_HOME%\pets` takes precedence over the default local path. |
| PENDING | Invalid local resource | Startup remains healthy and the menu reports the ignored-resource reason. |
| PENDING | Screen edges | Main pet and context menu remain inside every tested visible display bound. |
| PENDING | Multiple displays | Menu follows the cursor and placement works on each display, including negative coordinates when present. |
| PENDING | Quit | Quit closes all main/auxiliary windows and leaves no `DesktopPet.exe` process. |

Record defects and the commit containing each fix. Rebuild and repeat the full
artifact and smoke gates after any source change.

```text
Defects found:
Fix commits:
Retest notes:
```

## Internal Distribution Approval

| Result | Check |
| --- | --- |
| PENDING | Release notes say Windows internal alpha and do not claim general Windows support. |
| PENDING | Testers receive extraction, launch, SmartScreen exception, feedback, and uninstall instructions. |
| PENDING | The release commit is clean and matches the recorded SHA-256 artifact. |
| PENDING | The previous internal artifact remains available for rollback. |
| PENDING | Approver authorizes creating and pushing `v0.6.0`. |

```text
Approver:
Approval date:
Rollback artifact:
Feedback channel:
```

This candidate is not Authenticode signed. Microsoft Defender SmartScreen may
show a warning. That exception is acceptable only for the controlled internal
alpha audience; it is not sufficient for a general public Windows release.
