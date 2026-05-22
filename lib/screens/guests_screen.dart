import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/guest.dart';
import '../theme/app_theme.dart';

class GuestsScreen extends StatelessWidget {
  const GuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guests = context.watch<AppProvider>().guests;

    return Scaffold(
      appBar: AppBar(title: const Text('Guest Access')),
      body: guests.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: guests.length,
              itemBuilder: (context, i) => _GuestCard(guest: guests[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Guest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text('No guests yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('Share temporary access with guests', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AddGuestSheet(),
    );
  }
}

class _GuestCard extends StatelessWidget {
  final Guest guest;
  const _GuestCard({required this.guest});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final expired = guest.isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: expired || !guest.isActive ? AppColors.border.withOpacity(0.3) : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.secondary.withOpacity(guest.isActive && !expired ? 0.2 : 0.08),
                  child: Text(
                    guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppColors.secondary.withOpacity(guest.isActive && !expired ? 1.0 : 0.35),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest.name,
                        style: TextStyle(
                          color: guest.isActive && !expired ? AppColors.textPrimary : AppColors.textTertiary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(guest.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                _statusBadge(guest, expired),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.vpn_key_rounded, size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 5),
                Text('${guest.accessibleDoorIds.length} doors', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                if (guest.expiresAt != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.timer_outlined, size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 5),
                  Text(
                    expired
                        ? 'Expired ${DateFormat('MMM d').format(guest.expiresAt!)}'
                        : 'Until ${DateFormat('MMM d').format(guest.expiresAt!)}',
                    style: TextStyle(color: expired ? AppColors.danger : AppColors.textSecondary, fontSize: 12),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: () => provider.toggleGuestActive(guest.id),
                  child: Icon(
                    guest.isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => _confirmRemove(context, guest),
                  child: const Icon(Icons.delete_outline_rounded, size: 22, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(Guest guest, bool expired) {
    final Color color;
    final String label;
    if (expired) {
      color = AppColors.danger;
      label = 'Expired';
    } else if (!guest.isActive) {
      color = AppColors.textTertiary;
      label = 'Inactive';
    } else {
      color = AppColors.success;
      label = 'Active';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  void _confirmRemove(BuildContext context, Guest guest) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove Guest', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text("Remove ${guest.name}'s access?", style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().removeGuest(guest.id);
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _AddGuestSheet extends StatefulWidget {
  const _AddGuestSheet();

  @override
  State<_AddGuestSheet> createState() => _AddGuestSheetState();
}

class _AddGuestSheetState extends State<_AddGuestSheet> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final Set<String> _selectedDoorIds = {};
  DateTime? _expiresAt;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doors = context.watch<AppProvider>().doors;
    final canSave = _nameCtrl.text.trim().isNotEmpty && _selectedDoorIds.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Guest', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _label('Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecor('Full name'),
            ),
            const SizedBox(height: 14),
            _label('Email'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecor('email@example.com'),
            ),
            const SizedBox(height: 14),
            _label('Access to'),
            const SizedBox(height: 8),
            ...doors.map((door) {
              final sel = _selectedDoorIds.contains(door.id);
              return GestureDetector(
                onTap: () => setState(() => sel ? _selectedDoorIds.remove(door.id) : _selectedDoorIds.add(door.id)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withOpacity(0.1) : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: sel ? 1.5 : 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(sel ? Icons.check_circle_rounded : Icons.circle_outlined, size: 20, color: sel ? AppColors.primary : AppColors.textTertiary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(door.name, style: TextStyle(color: sel ? AppColors.primary : AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500))),
                      Text(door.location, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),
            _label('Access expires'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary)), child: child!),
                );
                if (date != null) setState(() => _expiresAt = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _expiresAt != null ? DateFormat('MMM d, yyyy').format(_expiresAt!) : 'No expiry (permanent)',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      ),
                    ),
                    if (_expiresAt != null)
                      GestureDetector(
                        onTap: () => setState(() => _expiresAt = null),
                        child: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textTertiary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSave
                    ? () {
                        context.read<AppProvider>().addGuest(Guest(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _nameCtrl.text.trim(),
                          email: _emailCtrl.text.trim(),
                          accessibleDoorIds: _selectedDoorIds.toList(),
                          expiresAt: _expiresAt,
                          createdAt: DateTime.now(),
                        ));
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Send Invite', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3));

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      );
}
