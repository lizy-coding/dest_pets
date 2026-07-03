# desktop_pet

Flutter 跨平台桌宠（Desktop Pet）PoC — 在 macOS 桌面上渲染一只透明无边框的宠物，支持拖拽移动、序列帧动画和位置记忆。

A cross-platform desktop pet (desktop mascot) PoC built with Flutter — renders a transparent, borderless pet on macOS with drag-to-move, frame-based animation, and position persistence.

---

## 功能特性 / Features

- 200×200 透明无边框窗口，隐藏标题栏和窗口按钮
- 窗口始终置顶（always-on-top）并加入所有 Spaces / 虚拟桌面
- Codex 标准宠物包（`pet.json` + `spritesheet.webp`）idle 动画播放
- 拖动宠物移动窗口，记住上一次位置
- 右键宠物可从本地 `${HOME}/.codex/pets` 选择个性宠物包
- 保留 Android、iOS、macOS 平台目录，便于后续扩展

---

## 技术栈 / Tech Stack

| Layer       | Technology                           |
|-------------|--------------------------------------|
| 框架        | Flutter (Dart SDK ^3.11.5)           |
| UI          | Material 3，透明主题                  |
| 窗口管理    | `window_manager` ^0.5.1              |
| 屏幕信息    | `screen_retriever` ^0.2.1            |
| 持久化      | `shared_preferences` ^2.5.5          |
| 宠物资产    | Codex pet package atlas (`1536×1872`) |
| 代码规范    | `flutter_lints` ^6.0.0               |
| 测试        | `flutter_test` (SDK)                 |

---

## 项目结构 / Project Structure

```
desktop_pet/
├── lib/
│   ├── main.dart                                    # 入口：初始化 settings → window → runApp
│   ├── app/
│   │   └── pet_app.dart                             # MaterialApp 根组件，透明主题
│   ├── desktop/
│   │   ├── desktop_window_controller.dart           # 跨平台窗口控制抽象层
│   │   └── macos_window_bootstrap.dart              # macOS 专属窗口初始化
│   ├── pet/
│   │   ├── pet_scene.dart                           # 场景：Scaffold + 居中布局
│   │   ├── pet_actor.dart                           # atlas 动画宠物渲染器
│   │   ├── pet_animation_controller.dart            # 可变帧时长动画控制器
│   │   ├── pet_atlas.dart                           # Codex pet atlas 常量
│   │   ├── pet_package.dart                         # 宠物包模型
│   │   ├── pet_package_repository.dart              # 默认/本地宠物包发现
│   │   └── pet_hit_area.dart                        # 拖拽手势区域
│   └── settings/
│       └── pet_settings.dart                        # SharedPreferences 位置与宠物选择持久化
├── assets/
│   └── pets/
│       └── default/
│           ├── pet.json                             # 默认宠物 manifest
│           └── spritesheet.webp                     # 默认宠物 atlas
├── test/
│   └── widget_test.dart                             # 宠物场景渲染验证
├── macos/                                           # macOS 平台原生代码
├── android/                                         # Android 平台原生代码
├── ios/                                             # iOS 平台原生代码
├── pubspec.yaml                                     # 依赖与 assets 声明
├── analysis_options.yaml                            # Lint 配置
└── README.md
```

### 模块职责 / Module Responsibilities

| 模块          | 路径                              | 职责 |
|---------------|-----------------------------------|------|
| **app**       | `lib/app/`                        | App 入口配置：MaterialApp 透明主题 |
| **desktop**   | `lib/desktop/`                    | 窗口控制抽象：初始化、拖动、位置监听、关闭 |
| **pet**       | `lib/pet/`                        | 核心域：场景布局、宠物包发现、atlas 动画渲染、手势交互 |
| **settings**  | `lib/settings/`                   | 持久化：窗口位置与宠物选择存取 |

---

## 快速开始 / Getting Started

### 环境要求 / Prerequisites

- Flutter SDK (stable, >=3.11.5)
- macOS (当前主要验证平台)

### 安装依赖 / Install

```sh
flutter pub get
```

### 运行 / Run

```sh
flutter run -d macos
```

### 构建 Release / Build

```sh
flutter build macos
open build/macos/Build/Products/Release/desktop_pet.app
```

---

## 开发指南 / Development

```sh
# 静态分析与代码检查
flutter analyze

# 运行测试
flutter test

# 升级依赖
flutter pub upgrade --major-versions

# 构建 Release
flutter build macos
```

---

## 架构说明 / Architecture

```
main.dart
  ├── PetSettings          ── SharedPreferences
  ├── DesktopWindowController
  │     ├── MacosWindowBootstrap (macOS only)
  │     └── window_manager listener
  └── PetApp
        └── PetScene
              ├── PetPackageRepository
              ├── RepaintBoundary
              └── PetHitArea (GestureDetector)
                    └── PetActor (atlas animation)
                          └── PetAnimationController
```

**关键模式：**

- **依赖注入**: `DesktopWindowController` 在 `main()` 创建，通过构造函数层层传递
- **平台抽象**: `DesktopWindowController` 封装跨平台窗口操作；`supportsNativeWindowControl` 守卫非桌面平台
- **宠物包发现**: `PetPackageRepository` 加载内置默认包，并发现 `${HOME}/.codex/pets/<pet-id>/`
- **atlas 动画**: `PetActor` 从 `1536×1872` spritesheet 中按 `192×208` cell 裁剪播放 idle 行
- **位置持久化**: 通过 250ms debounce 避免拖拽过程频繁写盘
- **宠物选择持久化**: 右键菜单选择的宠物包通过 `PetSettings` 保存

---

## 自定义宠物 / Custom Pets

应用支持 Codex 标准宠物包。将自定义宠物放到：

```text
${HOME}/.codex/pets/<pet-id>/
├── pet.json
└── spritesheet.webp
```

`pet.json` 示例：

```json
{
  "id": "mq",
  "displayName": "MQ",
  "description": "A calm gray amber-eyed companion cat for focused Codex work.",
  "spritesheetPath": "spritesheet.webp"
}
```

`spritesheet.webp` 应为 `1536×1872`，按 8 列 × 9 行组织，每格 `192×208`。当前应用先播放第 0 行 `idle` 状态；后续点击、等待、运行、失败等状态可继续映射到同一 atlas 的其他行。

运行应用后，右键宠物即可从内置默认宠物和本地自定义宠物包中切换。

---

## 路线图 / Roadmap

- [ ] 点击交互（切换 atlas 状态 / 响应触摸）
- [ ] 右键菜单（退出、设置）
- [ ] 状态栏菜单，托盘图标
- [x] 本地多套宠物外观切换
- [ ] 更完整的 macOS AppKit 插件能力
- [ ] Windows 平台支持
