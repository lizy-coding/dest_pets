import 'package:flutter/material.dart';

import '../model/pet_menu_action.dart';
import '../model/pet_runtime_mode.dart';
import '../model/pet_settings_snapshot.dart';

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

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xF7FFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x1F111827)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 24,
              offset: Offset(0, 10),
              color: Color(0x2E111827),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 236, maxWidth: 280),
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
                ),
                if (snapshot.hasError) ...[
                  _MenuMessage(
                    text: snapshot.errorMessage ?? 'Pet failed to load.',
                    isError: true,
                  ),
                  _MenuItem(
                    icon: Icons.refresh,
                    label: 'Recover',
                    onTap: () => onAction(
                      const PetMenuAction(PetMenuActionType.recoverFromError),
                    ),
                  ),
                  const _MenuDivider(),
                ] else ...[
                  _MenuMessage(
                    text:
                        '${snapshot.resourceOptions.length} resource'
                        '${snapshot.resourceOptions.length == 1 ? '' : 's'} available',
                  ),
                ],
                for (final resource in snapshot.resourceOptions)
                  _MenuItem(
                    icon: resource.selected ? Icons.check : Icons.pets,
                    label: resource.label,
                    trailing: resource.sourceLabel,
                    enabled: canUsePetCommands && !resource.selected,
                    onTap: () => onAction(
                      PetMenuAction(
                        PetMenuActionType.switchPet,
                        petId: resource.id,
                      ),
                    ),
                  ),
                if (snapshot.resourceOptions.isNotEmpty) const _MenuDivider(),
                _MenuItem(
                  icon: Icons.add,
                  label: 'Increase size',
                  trailing: _scaleLabel(snapshot.scale),
                  enabled: canUsePetCommands,
                  onTap: () => onAction(
                    const PetMenuAction(PetMenuActionType.increaseScale),
                  ),
                ),
                _MenuItem(
                  icon: Icons.remove,
                  label: 'Decrease size',
                  enabled: canUsePetCommands,
                  onTap: () => onAction(
                    const PetMenuAction(PetMenuActionType.decreaseScale),
                  ),
                ),
                _MenuItem(
                  icon: Icons.restart_alt,
                  label: 'Reset size',
                  enabled: canUsePetCommands,
                  onTap: () => onAction(
                    const PetMenuAction(PetMenuActionType.resetScale),
                  ),
                ),
                const _MenuDivider(),
                _MenuItem(
                  icon: snapshot.alwaysOnTop
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  label: 'Always on top',
                  trailing: snapshot.alwaysOnTop ? 'On' : 'Off',
                  onTap: () => onAction(
                    const PetMenuAction(PetMenuActionType.toggleAlwaysOnTop),
                  ),
                ),
                _MenuItem(
                  icon: Icons.sync,
                  label: 'Refresh resources',
                  onTap: () => onAction(
                    const PetMenuAction(PetMenuActionType.refreshResources),
                  ),
                ),
                _MenuItem(
                  icon: Icons.restore,
                  label: 'Reset config',
                  onTap: () => onAction(
                    const PetMenuAction(PetMenuActionType.resetConfig),
                  ),
                ),
                const _MenuDivider(),
                _MenuItem(
                  icon: Icons.close,
                  label: 'Quit',
                  onTap: () =>
                      onAction(const PetMenuAction(PetMenuActionType.quit)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
  });

  final String title;
  final String status;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final statusColor = hasError
        ? const Color(0xFFB91C1C)
        : const Color(0xFF047857);

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
                  style: const TextStyle(
                    color: Color(0xFF111827),
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
    this.trailing,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled
        ? const Color(0xFF1F2937)
        : const Color(0xFF9CA3AF);

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
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
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
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
    );
  }
}

class _MenuMessage extends StatelessWidget {
  const _MenuMessage({required this.text, this.isError = false});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final foreground = isError
        ? const Color(0xFFB91C1C)
        : const Color(0xFF4B5563);
    final background = isError
        ? const Color(0xFFFFF1F2)
        : const Color(0xFFF9FAFB);
    final border = isError ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB);

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
