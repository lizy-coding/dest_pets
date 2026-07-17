# Desktop Pet

[English](README.md) | [中文](README.zh-CN.md)

`desktop_pet` 是一个 Flutter 桌面宠物 PoC。它在透明、无边框、置顶的桌面窗口中渲染 Codex atlas 宠物动画，支持拖动、右键菜单、本地宠物资源发现，并持久化当前宠物、缩放、置顶偏好和窗口位置。

## 示例

![Desktop Pet 示例](view/mq.gif)

## 状态

当前已验证内部版本：macOS `v0.5.0`。

下一候选版本：Windows 内部 alpha `v0.6.0`。源码、产品元数据、图标、
打包校验和自动化测试接缝已经准备完成；发布仍以 Windows 主机完成构建并记录
手工冒烟清单为前置条件。

## 功能

- 透明 200x200 macOS 宠物窗口，隐藏标题栏和窗口按钮。
- 窗口可置顶，并可跨 macOS Spaces 显示。
- 内置默认 Codex atlas 宠物资源：`assets/pets/default_pet/`。
- 从 `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/` 发现本地宠物资源。
- 严格解析规范化 `pet.json` manifest。
- 右键菜单会显示被忽略的本地资源及原因摘要。
- 基于 atlas 的 `idle` 动画，帧序列和时长由 manifest 定义。
- 运行时动画状态可按 animation id 切换；资源未定义可选动画时回退到 `idle`。
- 拖动移动窗口，并持久化窗口位置。
- 右键辅助窗口菜单支持宠物切换、尺寸控制、置顶切换、资源刷新、重置配置、错误恢复和退出。
- 主窗口和辅助菜单窗口对显示器 API 失败有安全 fallback。
- 项目专用 macOS app icon 资源。
- 与 macOS 一致的项目专用 Windows 图标和产品元数据。
- 配置持久化统一通过 `SettingsStore`。
- 运行时行为统一通过 `PetController` 和 `PetState` 管理。

## 已知限制

- 右键菜单仍是紧凑工具型 UI，不是最终生产视觉。
- 应用仅做 ad-hoc 签名，未做 Developer ID 签名和 notarization，首次启动需要右键 Open。
- Windows 内部 alpha 候选未做 Authenticode 签名，可能触发 Microsoft
  Defender SmartScreen。
- Windows 发布清单通过前，macOS 仍是唯一完成验证的平台。

## 环境要求

- Flutter SDK，兼容 Dart `^3.11.5`
- macOS，用于当前已验证桌面目标
- Windows 与可用的 Flutter 桌面工具链，用于候选版本验证

## 运行

```sh
flutter pub get
flutter run -d macos
```

Windows：

```bat
flutter pub get
flutter run -d windows
```

## 构建与打包

Debug 构建：

```sh
flutter build macos --debug
open "build/macos/Build/Products/Debug/Desktop Pet.app"
```

Release 构建：

```sh
flutter build macos --release
open "build/macos/Build/Products/Release/Desktop Pet.app"
```

生成 DMG：

```sh
bash scripts/package_dmg.sh
```

输出路径：`dist/Desktop Pet-<version>.dmg`

Windows Release ZIP 与 SHA-256：

```bat
scripts\package_windows.bat
```

输出路径：

```text
dist/Desktop Pet-<version>-windows-x64.zip
dist/Desktop Pet-<version>-windows-x64.zip.sha256
```

## 安装 Windows 内部 Alpha

1. 将 ZIP 和对应的 `.sha256` 文件下载到同一目录。
2. 在 PowerShell 中校验 ZIP：

   ```powershell
   Get-FileHash "Desktop Pet-0.6.0-windows-x64.zip" -Algorithm SHA256
   ```

   确认输出哈希与 `.sha256` 文件中的第一项完全一致。
3. 将 ZIP 完整解压到普通目录，不要直接在压缩包内运行程序。
4. 启动 `DesktopPet.exe`。内部 alpha 未签名，Microsoft Defender
   SmartScreen 可能需要点击“更多信息”，然后选择“仍要运行”。
5. 卸载时先退出 Desktop Pet，再删除解压目录；仅当不再需要本地宠物时删除
   `%USERPROFILE%\.codex\pets`。如需彻底重置，可再清理 Windows 应用设置数据。

只有在 ZIP 的 SHA-256 与内部版本负责人提供的值一致时，才允许使用
SmartScreen 例外。

## 从 DMG 安装

1. 双击 DMG 挂载磁盘镜像。
2. 将 `Desktop Pet` 拖入 `Applications`。
3. 首次启动时，在 Applications 中右键应用并选择 **Open**。
4. Gatekeeper 弹窗出现后点击 **Open**。
5. 后续启动可正常双击。

## macOS 桌面行为

- 主宠物窗口透明、无边框、固定尺寸，并支持拖动。
- macOS alpha 阶段应用仍是普通 Dock app。
- 宠物窗口默认置顶，并配置为跨 Spaces 显示。
- 右键菜单在临时辅助窗口中打开，不进入任务切换，并在失焦时关闭。
- 如果显示器信息读取失败，应用会回退到安全屏幕位置，而不是启动失败。

## 验证

```sh
dart format lib test
flutter analyze
flutter test
flutter build macos --debug
flutter build macos --release
bash scripts/package_dmg.sh
```

## 宠物资源格式

内置资源：

```text
assets/pets/default_pet/
├── pet.json
└── spritesheet.webp
```

本地资源：

```text
${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/
├── pet.json
└── spritesheet.webp
```

Manifest 结构：

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

无效 manifest、不安全相对路径、缺失 spritesheet、缺失 atlas 数据、缺失 `idle` 动画的资源会被运行时忽略。被忽略的本地资源会在右键菜单中摘要显示。内置资源无效时初始化应失败。

## 架构

```text
lib/
├── app/
│   ├── app.dart
│   └── pet_menu_window_app.dart
├── desktop/
│   ├── auxiliary_window_arguments.dart
│   ├── auxiliary_window_bootstrap.dart
│   ├── auxiliary_window_controller.dart
│   ├── desktop_auxiliary_window_controller.dart
│   ├── desktop_window_controller.dart
│   ├── macos_window_bootstrap.dart
│   ├── platform_capabilities.dart
│   ├── window_bootstrap.dart
│   └── windows_window_bootstrap.dart
├── pet/
│   ├── animation/
│   ├── controller/pet_controller.dart
│   ├── model/
│   └── view/
├── resources/
│   ├── data/pet_resource_repository.dart
│   └── model/
└── settings/settings_store.dart
```

主窗口运行流：

```text
main.dart
  -> SettingsStore
  -> WindowBootstrap (MacosWindowBootstrap | WindowsWindowBootstrap)
  -> DesktopWindowController
  -> DesktopAuxiliaryWindowController
  -> App
       -> PetResourceRepository
       -> PetController
       -> PetView
            -> PetHitArea
            -> PetActor
```

辅助菜单窗口运行流：

```text
main.dart
  -> AuxiliaryWindowArguments
  -> AuxiliaryWindowBootstrap
  -> PetMenuWindowApp
       -> PetContextMenu
```

## Windows 发布验证

Windows 已准备为内部 alpha 候选，但尚未成为正式支持平台。必须在 Windows
主机上完成并记录 [WINDOWS_INTERNAL_ALPHA_CHECKLIST.md](WINDOWS_INTERNAL_ALPHA_CHECKLIST.md)：

- 运行 `scripts\package_windows.bat`，确认 Release 构建、运行文件检查、ZIP
  和 SHA-256 全部成功。
- 校验 SHA-256，并从最终 ZIP 解压后的目录启动。
- 验证透明无边框、置顶、拖动和位置持久化。
- 验证右键菜单打开、操作和失焦关闭。
- 验证 `%USERPROFILE%\.codex\pets` 与 `CODEX_HOME\pets`。
- 验证多显示器和屏幕边缘定位。
- 验证退出后没有残留进程，并在第二个 Windows 账户或机器上启动。

## 路线图摘要

完整路线见 `EVOLUTION_PLAN.md`。当前优先级：

1. 执行并记录 macOS v0.5 手工烟测矩阵。
2. 发布给终端用户前，补 Developer ID 签名和 notarization。
3. 在 Windows 主机上完成并记录发布清单后，才把 Windows 标记为支持平台。
