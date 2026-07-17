enum DesktopPlatform { macos, windows, linux, other }

class LocalPetsDirectoryResolver {
  const LocalPetsDirectoryResolver({
    required this.environment,
    required this.platform,
  });

  final Map<String, String> environment;
  final DesktopPlatform platform;

  String? resolve() {
    final codexHome = _nonEmpty(environment['CODEX_HOME']);
    if (codexHome != null) {
      return '$codexHome/pets';
    }

    final home = switch (platform) {
      DesktopPlatform.windows => _nonEmpty(environment['USERPROFILE']),
      DesktopPlatform.macos ||
      DesktopPlatform.linux => _nonEmpty(environment['HOME']),
      DesktopPlatform.other => null,
    };

    if (home == null) {
      return null;
    }

    return '$home/.codex/pets';
  }
}

String? _nonEmpty(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}
