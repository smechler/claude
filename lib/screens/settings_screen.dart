import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _sectionHeader('Profile'),
          _card([
            _editableTile(context, icon: Icons.person_rounded, color: AppColors.secondary, label: 'Your Name', value: provider.userName, onSave: provider.setUserName),
            _divider(),
            _editableTile(context, icon: Icons.apartment_rounded, color: AppColors.secondary, label: 'Unit Number', value: provider.unitNumber, onSave: provider.setUnitNumber),
            _divider(),
            _editableTile(context, icon: Icons.location_city_rounded, color: AppColors.secondary, label: 'Community Name', value: provider.communityName, onSave: provider.setCommunityName),
          ]),
          _sectionHeader('Controls'),
          _card([
            _switchTile(
              icon: Icons.swipe_rounded,
              label: 'Slide to Open',
              subtitle: 'Replace tap buttons with slide gestures',
              value: provider.useSlideToOpen,
              onChanged: provider.setUseSlideToOpen,
            ),
          ]),
          _sectionHeader('Notifications'),
          _card([
            _switchTile(
              icon: Icons.notifications_rounded,
              label: 'Push Notifications',
              subtitle: 'Alerts when doors are opened',
              value: provider.notificationsEnabled,
              onChanged: provider.setNotificationsEnabled,
            ),
            _divider(),
            _switchTile(
              icon: Icons.vibration_rounded,
              label: 'Haptic Feedback',
              subtitle: 'Vibrate when opening doors',
              value: provider.hapticFeedback,
              onChanged: provider.setHapticFeedback,
            ),
          ]),
          _sectionHeader('Support'),
          _card([
            _navTile(icon: Icons.help_outline_rounded, label: 'Help & FAQ', onTap: () {}),
            _divider(),
            _navTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
            _divider(),
            _navTile(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () {}),
          ]),
          const SizedBox(height: 20),
          const Center(
            child: Text('CondoKey v1.0.0', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
        child: Text(title.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(children: children),
      );

  Widget _divider() => const Divider(color: AppColors.border, height: 1, indent: 56);

  Widget _switchTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _iconBox(icon, AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(value: value, activeColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _editableTile(BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required Future<void> Function(String) onSave,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _iconBox(icon, color),
      title: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
      onTap: () => _showEditDialog(context, label: label, value: value, onSave: onSave),
    );
  }

  Widget _navTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _iconBox(icon, AppColors.textSecondary, bg: AppColors.cardElevated),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
      onTap: onTap,
    );
  }

  Widget _iconBox(IconData icon, Color color, {Color? bg}) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg ?? color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: color),
      );

  void _showEditDialog(BuildContext context, {required String label, required String value, required Future<void> Function(String) onSave}) {
    final ctrl = TextEditingController(text: value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit $label', style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              onSave(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
