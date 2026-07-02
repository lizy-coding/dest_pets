# desktop_pet

Flutter 跨平台桌宠 PoC，当前阶段优先验证 macOS 透明无边框窗口和透明 PNG 宠物渲染。

## 当前能力

- macOS 启动 200x200 透明窗口
- 隐藏系统标题栏和窗口按钮
- 窗口置顶并加入所有 Spaces
- 渲染透明 PNG 序列帧 idle 动画
- 支持拖动宠物移动窗口
- 记录窗口上一次位置
- 保留 android、ios、macos 平台目录

## 运行

```sh
flutter run -d macos
```

构建 release app：

```sh
flutter build macos
open build/macos/Build/Products/Release/desktop_pet.app
```

## 目录

```text
lib/
├── app/
├── desktop/
├── pet/
└── settings/

assets/
└── pets/
    └── default/
```

下一阶段可以继续加点击动作切换、右键菜单、状态栏菜单和更完整的 macOS AppKit 插件能力。
