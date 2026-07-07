class PlatformCapabilities {
  const PlatformCapabilities({
    required this.supportsTransparency,
    required this.supportsClickThrough,
    required this.supportsTray,
    required this.supportsLaunchAtStartup,
    required this.supportsGlobalShortcut,
  });

  const PlatformCapabilities.none()
    : supportsTransparency = false,
      supportsClickThrough = false,
      supportsTray = false,
      supportsLaunchAtStartup = false,
      supportsGlobalShortcut = false;

  final bool supportsTransparency;
  final bool supportsClickThrough;
  final bool supportsTray;
  final bool supportsLaunchAtStartup;
  final bool supportsGlobalShortcut;
}
