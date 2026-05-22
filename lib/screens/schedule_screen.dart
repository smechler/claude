import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/scheduled_access.dart';
import '../models/door.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schedules = context.watch<AppProvider>().schedules;

    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Access')),
      body: schedules.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: schedules.length,
              itemBuilder: (context, i) => _ScheduleCard(schedule: schedules[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_rounded, size: 64, color: AppColors.textTertiary),
          SizedBox(height: 16),
          Text('No scheduled access', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('Tap + to schedule automatic door openings', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
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
      builder: (_) => const _AddScheduleSheet(),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduledAccess schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.isActive ? AppColors.border : AppColors.border.withValues(alpha: 0.3),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: schedule.isActive ? 0.15 : 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.schedule_rounded, color: AppColors.warning.withValues(alpha: schedule.isActive ? 1.0 : 0.35), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.doorName,
                        style: TextStyle(
                          color: schedule.isActive ? AppColors.textPrimary : AppColors.textTertiary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (schedule.note != null) ...[
                        const SizedBox(height: 2),
                        Text(schedule.note!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: schedule.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (_) => provider.toggleScheduleActive(schedule.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _Chip(icon: Icons.access_time_rounded, label: DateFormat('MMM d, h:mm a').format(schedule.scheduledAt)),
                const SizedBox(width: 8),
                _Chip(icon: Icons.repeat_rounded, label: schedule.recurrenceLabel),
                const Spacer(),
                GestureDetector(
                  onTap: () => provider.removeSchedule(schedule.id),
                  child: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.cardElevated, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AddScheduleSheet extends StatefulWidget {
  const _AddScheduleSheet();

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  Door? _door;
  DateTime _dt = DateTime.now().add(const Duration(hours: 1));
  RecurrenceType _recurrence = RecurrenceType.once;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doors = context.watch<AppProvider>().doors;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Schedule Access', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _label('Door / Gate'),
            const SizedBox(height: 8),
            DropdownButtonFormField<Door>(
              value: _door,
              hint: const Text('Select a door', style: TextStyle(color: AppColors.textTertiary)),
              dropdownColor: AppColors.surface,
              decoration: _inputDecor(),
              items: doors.map((d) => DropdownMenuItem(value: d, child: Text(d.name, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
              onChanged: (d) => setState(() => _door = d),
            ),
            const SizedBox(height: 16),
            _label('Date & Time'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dt,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary)), child: child!),
                );
                if (date != null && mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dt),
                    builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary)), child: child!),
                  );
                  if (time != null) setState(() => _dt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(DateFormat('MMM d, yyyy – h:mm a').format(_dt), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _label('Repeat'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: RecurrenceType.values.map((r) {
                  final sel = _recurrence == r;
                  final labels = {RecurrenceType.once: 'Once', RecurrenceType.daily: 'Daily', RecurrenceType.weekly: 'Weekly', RecurrenceType.weekdays: 'Weekdays'};
                  return GestureDetector(
                    onTap: () => setState(() => _recurrence = r),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(labels[r]!, style: TextStyle(color: sel ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _label('Note (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecor(hint: 'e.g. Plumber visit, Dog walker...'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _door == null
                    ? null
                    : () {
                        context.read<AppProvider>().addSchedule(ScheduledAccess(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          doorId: _door!.id,
                          doorName: _door!.name,
                          scheduledAt: _dt,
                          recurrence: _recurrence,
                          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
                        ));
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Schedule', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3));

  InputDecoration _inputDecor({String? hint}) => InputDecoration(
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
