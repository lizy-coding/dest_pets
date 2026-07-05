# Desktop Pet

[English](README.md) | [中文](README.zh-CN.md)

`desktop_pet` 是一个 Flutter macOS 桌面宠物 PoC。它在透明、无边框、置顶的桌面窗口中渲染 Codex atlas 宠物动画，支持拖动、右键菜单、本地宠物资源发现，并持久化当前宠物、缩放、置顶偏好和窗口位置。

## 状态

当前版本：`v0.1.1`

发布状态：macOS 内部 alpha。核心路径已通过自动化验证，应用可运行；右键菜单已迁移到辅助窗口并修正屏幕坐标锚点，但视觉仍偏基础。

## 功能

- 透明 200x200 macOS 宠物窗口，隐藏标题栏和窗口按钮。
- 窗口可置顶，并可跨 macOS Spaces 显示。
- 内置默认 Codex atlas 宠物资源：`assets/pets/default_pet/`。
- 从 `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/` 发现本地宠物资源。
- 严格解析规范化 `pet.json` manifest。
- 基于 atlas 的 `idle` 动画，帧序列和时长由 manifest 定义。
- 拖动移动窗口，并持久化窗口位置。
- 右键辅助窗口菜单支持宠物切换、尺寸控制、置顶切换、资源刷新、重置配置、错误恢复和退出。
- 配置持久化统一通过 `SettingsStore`。
- 运行时行为统一通过 `PetController` 和 `PetState` 管理。

## 已知限制

- 右键菜单视觉仍较基础。
- 应用仅做 ad-hoc 签名，未做 Developer ID 签名和 notarization，首次启动需要右键 Open。
- 当前版本只验证 macOS。

## 环境要求

- Flutter SDK，兼容 Dart `^3.11.5`
- macOS，用于当前已验证桌面目标

## 运行

```sh
flutter pub get
flutter run -d macos
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

## 从 DMG 安装

1. 双击 DMG 挂载磁盘镜像。
2. 将 `Desktop Pet` 拖入 `Applications`。
3. 首次启动时，在 Applications 中右键应用并选择 **Open**。
4. Gatekeeper 弹窗出现后点击 **Open**。
5. 后续启动可正常双击。

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

无效 manifest、不安全相对路径、缺失 spritesheet、缺失 atlas 数据、缺失 `idle` 动画的资源会被忽略。内置资源无效时初始化应失败。

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
│   └── macos_window_bootstrap.dart
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

## 路线图摘要

完整路线见 `EVOLUTION_PLAN.md`。当前优先级：

1. 改善菜单视觉、错误态展示和设置入口，但不引入大型设置页。
2. 增强本地资源校验报告，让用户知道资源为什么被忽略。
3. 扩展动画行为前，先保持 `PetActor` 只负责渲染。
4. 发布给终端用户前，补 app icon、Developer ID 签名和 notarization。
