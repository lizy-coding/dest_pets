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

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xF2FFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x22000000)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 24,
              offset: Offset(0, 10),
              color: Color(0x33000000),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 236, maxWidth: 280),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (snapshot.hasError) ...[
                  _MenuLabel(
                    text: snapshot.errorMessage ?? 'Pet failed to load.',
                  ),
                  _MenuItem(
                    icon: Icons.refresh,
                    label: 'Recover',
                    onTap: () => onAction(
                      const PetMenuAction(PetMenuActionType.recoverFromError),
                    ),
                  ),
                  const _MenuDivider(),
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
              Text(
                trailing!,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
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
    return const Divider(height: 9, thickness: 1, color: Color(0xFFE5E7EB));
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
      ),
    );
  }
}
