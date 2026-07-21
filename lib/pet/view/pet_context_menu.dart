import 'package:flutter/material.dart';

import '../model/pet_menu_action.dart';
import '../model/pet_runtime_mode.dart';
import '../model/pet_settings_snapshot.dart';
import '../../resources/model/pet_resource_discovery_result.dart';

class _ContextMenuColors {
  const _ContextMenuColors(this._isDark);

  final bool _isDark;

  Color get containerBackground =>
      _isDark ? const Color(0xF7242424) : const Color(0xF7FFFFFF);
  Color get containerBorder =>
      _isDark ? const Color(0x1FFFFFFF) : const Color(0x1F111827);
  Color get containerShadow =>
      _isDark ? const Color(0x2E000000) : const Color(0x2E111827);
  Color get titleText =>
      _isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
  Color get itemForeground =>
      _isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937);
  Color get itemDisabled =>
      _isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
  Color get trailingText =>
      _isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  Color get divider =>
      _isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  Color get infoBg =>
      _isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB);
  Color get infoBorder =>
      _isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB);
  Color get infoText =>
      _isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563);
  Color get errorBg =>
      _isDark ? const Color(0xFF450A0A) : const Color(0xFFFFF1F2);
  Color get errorBorder =>
      _isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA);
  Color get warningBg =>
      _isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB);
  Color get warningBorder =>
      _isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A);
  Color get warningTitle =>
      _isDark ? const Color(0xFFFED7AA) : const Color(0xFF92400E);
  Color get warningText =>
      _isDark ? const Color(0xFFFDBA74) : const Color(0xFF78350F);

  static const Color statusError = Color(0xFFB91C1C);
  static const Color statusSuccess = Color(0xFF047857);
}

class PetContextMenu extends StatelessWidget {
  const PetContextMenu({
    required this.snapshot,
    required this.onAction,
    super.key,
  });

  final PetSettingsSnapshot snapshot;
  final ValueChanged<PetMenuAction> onAction;

  @override
  Widget build(BuildContext context) {
    final canUsePetCommands =
        snapshot.runtimeMode != PetRuntimeMode.error &&
        snapshot.resourceOptions.isNotEmpty;
    final selectedResource = _selectedResourceLabel(snapshot);
    final status = _statusText(snapshot.runtimeMode);
    final colors = _ContextMenuColors(
      Theme.of(context).brightness == Brightness.dark,
    );

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.containerBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.containerBorder),
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              offset: const Offset(0, 10),
              color: colors.containerShadow,
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 236,
            maxWidth: 280,
            maxHeight: 420,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MenuHeader(
                    title: selectedResource ?? snapshot.petId,
                    status: status,
                    hasError: snapshot.hasError,
                    colors: colors,
                  ),
                  if (snapshot.hasError) ...[
                    _MenuMessage(
                      text: snapshot.errorMessage ?? 'Pet failed to load.',
                      isError: true,
                      colors: colors,
                    ),
                    _MenuItem(
                      icon: Icons.refresh,
                      label: 'Recover',
                      colors: colors,
                      onTap: () => onAction(
                        const PetMenuAction(PetMenuActionType.recoverFromError),
                      ),
                    ),
                    _MenuDivider(colors: colors),
                  ] else ...[
                    _MenuMessage(
                      text: _resourceSummary(snapshot),
                      colors: colors,
                    ),
                  ],
                  for (final resource in snapshot.resourceOptions)
                    _MenuItem(
                      icon: resource.selected ? Icons.check : Icons.pets,
                      label: resource.label,
                      trailing: resource.sourceLabel,
                      enabled: canUsePetCommands && !resource.selected,
                      colors: colors,
                      onTap: () => onAction(
                        PetMenuAction(
                          PetMenuActionType.switchPet,
                          petId: resource.id,
                        ),
                      ),
                    ),
                  if (snapshot.ignoredResourceReports.isNotEmpty) ...[
                    _MenuDivider(colors: colors),
                    _IgnoredResourceSection(
                      reports: snapshot.ignoredResourceReports,
                      colors: colors,
                    ),
                  ],
                  if (snapshot.resourceOptions.isNotEmpty)
                    _MenuDivider(colors: colors),
                  _MenuItem(
                    icon: Icons.add,
                    label: 'Increase size',
                    trailing: _scaleLabel(snapshot.scale),
                    enabled: canUsePetCommands,
                    colors: colors,
                    onTap: () => onAction(
                      const PetMenuAction(PetMenuActionType.increaseScale),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.remove,
                    label: 'Decrease size',
                    enabled: canUsePetCommands,
                    colors: colors,
                    onTap: () => onAction(
                      const PetMenuAction(PetMenuActionType.decreaseScale),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.restart_alt,
                    label: 'Reset size',
                    enabled: canUsePetCommands,
                    colors: colors,
                    onTap: () => onAction(
                      const PetMenuAction(PetMenuActionType.resetScale),
                    ),
                  ),
                  _MenuDivider(colors: colors),
                  _MenuItem(
                    icon: snapshot.alwaysOnTop
                        ? Icons.push_pin
                        : Icons.push_pin_outlined,
                    label: 'Always on top',
                    trailing: snapshot.alwaysOnTop ? 'On' : 'Off',
                    colors: colors,
                    onTap: () => onAction(
                      const PetMenuAction(PetMenuActionType.toggleAlwaysOnTop),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.sync,
                    label: 'Refresh resources',
                    colors: colors,
                    onTap: () => onAction(
                      const PetMenuAction(PetMenuActionType.refreshResources),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.restore,
                    label: 'Reset config',
                    colors: colors,
                    onTap: () => onAction(
                      const PetMenuAction(PetMenuActionType.resetConfig),
                    ),
                  ),
                  _MenuDivider(colors: colors),
                  _MenuItem(
                    icon: Icons.close,
                    label: 'Quit',
                    colors: colors,
                    onTap: () =>
                        onAction(const PetMenuAction(PetMenuActionType.quit)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _resourceSummary(PetSettingsSnapshot snapshot) {
  final validCount = snapshot.resourceOptions.length;
  final ignoredCount = snapshot.ignoredResourceReports.length;
  final validLabel = '$validCount resource${validCount == 1 ? '' : 's'}';
  if (ignoredCount == 0) {
    return '$validLabel available';
  }

  return '$validLabel available, $ignoredCount ignored';
}

String _statusText(PetRuntimeMode mode) {
  return switch (mode) {
    PetRuntimeMode.initializing => 'Starting',
    PetRuntimeMode.idle => 'Ready',
    PetRuntimeMode.dragging => 'Moving',
    PetRuntimeMode.switchingResource => 'Switching',
    PetRuntimeMode.error => 'Needs recovery',
  };
}

String _scaleLabel(double scale) {
  return '${(scale * 100).round()}%';
}

String? _selectedResourceLabel(PetSettingsSnapshot snapshot) {
  for (final resource in snapshot.resourceOptions) {
    if (resource.selected) {
      return resource.label;
    }
  }

  return null;
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.title,
    required this.status,
    required this.hasError,
    required this.colors,
  });

  final String title;
  final String status;
  final bool hasError;
  final _ContextMenuColors colors;

  @override
  Widget build(BuildContext context) {
    final statusColor = hasError
        ? _ContextMenuColors.statusError
        : _ContextMenuColors.statusSuccess;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withValues(alpha: 0.18)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Icon(Icons.pets, size: 17, color: statusColor),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.titleText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colors,
    this.trailing,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final bool enabled;
  final _ContextMenuColors colors;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled ? colors.itemForeground : colors.itemDisabled;

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  trailing!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.trailingText, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider({required this.colors});

  final _ContextMenuColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, thickness: 1, color: colors.divider),
    );
  }
}

class _IgnoredResourceSection extends StatelessWidget {
  const _IgnoredResourceSection({required this.reports, required this.colors});

  final List<PetResourceValidationReport> reports;
  final _ContextMenuColors colors;

  @override
  Widget build(BuildContext context) {
    final visibleReports = reports.take(3).toList(growable: false);
    final remainingCount = reports.length - visibleReports.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.warningBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.warningBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${reports.length} ignored resource'
                '${reports.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: colors.warningTitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              for (final report in visibleReports)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '${_resourceDirectoryName(report.directoryPath)}: '
                    '${_reasonLabel(report.reason)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.warningText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (remainingCount > 0)
                Text(
                  '+$remainingCount more',
                  style: TextStyle(
                    color: colors.warningTitle,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _resourceDirectoryName(String path) {
  final normalized = path.replaceAll(r'\', '/');
  final segments = normalized
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);
  if (segments.isEmpty) {
    return path;
  }

  return segments.last;
}

String _reasonLabel(PetResourceValidationReason reason) {
  return switch (reason) {
    PetResourceValidationReason.missingManifest => 'missing pet.json',
    PetResourceValidationReason.invalidManifest => 'invalid pet.json',
    PetResourceValidationReason.missingSpritesheet => 'missing spritesheet',
    PetResourceValidationReason.unreadableResource => 'unreadable files',
    PetResourceValidationReason.unreadableDirectory => 'unreadable pets folder',
  };
}

class _MenuMessage extends StatelessWidget {
  const _MenuMessage({
    required this.text,
    required this.colors,
    this.isError = false,
  });

  final String text;
  final bool isError;
  final _ContextMenuColors colors;

  @override
  Widget build(BuildContext context) {
    final foreground = isError
        ? _ContextMenuColors.statusError
        : colors.infoText;
    final background = isError ? colors.errorBg : colors.infoBg;
    final border = isError ? colors.errorBorder : colors.infoBorder;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
