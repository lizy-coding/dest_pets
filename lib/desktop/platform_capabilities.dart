import 'dart:io';

import 'package:flutter/foundation.dart';

enum DesktopPlatform { macos, windows, linux, other }

class PlatformCapabilities {
  const PlatformCapabilities({
    required this.platform,
    required this.supportsNativeWindowControl,
    required this.supportsAuxiliaryWindows,
    required this.supportsTransparency,
    required this.supportsClickThrough,
    required this.supportsTray,
    required this.supportsLaunchAtStartup,
    required this.supportsGlobalShortcut,
  });

  const PlatformCapabilities.none()
    : platform = DesktopPlatform.other,
      supportsNativeWindowControl = false,
      supportsAuxiliaryWindows = false,
      supportsTransparency = false,
      supportsClickThrough = false,
      supportsTray = false,
      supportsLaunchAtStartup = false,
      supportsGlobalShortcut = false;

  factory PlatformCapabilities.current() {
    if (kIsWeb) {
      return const PlatformCapabilities.none();
    }

    final platform = _currentDesktopPlatform();
    final supportsNativeWindowControl =
        platform == DesktopPlatform.macos ||
        platform == DesktopPlatform.windows ||
        platform == DesktopPlatform.linux;
    if (!supportsNativeWindowControl) {
      return const PlatformCapabilities.none();
    }

    return PlatformCapabilities(
      platform: platform,
      supportsNativeWindowControl: true,
      supportsAuxiliaryWindows: true,
      supportsTransparency:
          platform == DesktopPlatform.macos ||
          platform == DesktopPlatform.windows,
      supportsClickThrough:
          platform == DesktopPlatform.macos ||
          platform == DesktopPlatform.windows,
      supportsTray: true,
      supportsLaunchAtStartup:
          platform == DesktopPlatform.macos ||
          platform == DesktopPlatform.windows,
      supportsGlobalShortcut: false,
    );
  }

  final DesktopPlatform platform;
  final bool supportsNativeWindowControl;
  final bool supportsAuxiliaryWindows;
  final bool supportsTransparency;
  final bool supportsClickThrough;
  final bool supportsTray;
  final bool supportsLaunchAtStartup;
  final bool supportsGlobalShortcut;
}

DesktopPlatform _currentDesktopPlatform() {
  if (Platform.isMacOS) {
    return DesktopPlatform.macos;
  }

  if (Platform.isWindows) {
    return DesktopPlatform.windows;
  }

  if (Platform.isLinux) {
    return DesktopPlatform.linux;
  }

  return DesktopPlatform.other;
}
