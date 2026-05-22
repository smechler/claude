enum RecurrenceType { once, daily, weekly, weekdays }

class ScheduledAccess {
  final String id;
  final String doorId;
  final String doorName;
  DateTime scheduledAt;
  RecurrenceType recurrence;
  bool isActive;
  String? note;

  ScheduledAccess({
    required this.id,
    required this.doorId,
    required this.doorName,
    required this.scheduledAt,
    this.recurrence = RecurrenceType.once,
    this.isActive = true,
    this.note,
  });

  String get recurrenceLabel {
    switch (recurrence) {
      case RecurrenceType.once:
        return 'One time';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.weekdays:
        return 'Weekdays';
    }
  }

  static List<ScheduledAccess> mockSchedules() {
    final now = DateTime.now();
    return [
      ScheduledAccess(
        id: '1',
        doorId: '1',
        doorName: 'Main Gate',
        scheduledAt: DateTime(now.year, now.month, now.day + 1, 9, 0),
        recurrence: RecurrenceType.once,
        note: 'Plumber visit',
      ),
      ScheduledAccess(
        id: '2',
        doorId: '4',
        doorName: 'Gym Entrance',
        scheduledAt: DateTime(now.year, now.month, now.day, 7, 0),
        recurrence: RecurrenceType.weekdays,
        note: 'Morning workout',
      ),
      ScheduledAccess(
        id: '3',
        doorId: '2',
        doorName: 'Pool Gate',
        scheduledAt: DateTime(now.year, now.month, now.day + 3, 14, 0),
        recurrence: RecurrenceType.weekly,
      ),
    ];
  }
}
