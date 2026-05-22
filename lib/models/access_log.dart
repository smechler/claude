class AccessLog {
  final String id;
  final String doorId;
  final String doorName;
  final String openedBy;
  final DateTime openedAt;
  final bool wasSuccessful;

  AccessLog({
    required this.id,
    required this.doorId,
    required this.doorName,
    required this.openedBy,
    required this.openedAt,
    this.wasSuccessful = true,
  });

  static List<AccessLog> mockLogs() {
    final now = DateTime.now();
    return [
      AccessLog(id: '1', doorId: '1', doorName: 'Main Gate', openedBy: 'You', openedAt: now.subtract(const Duration(hours: 2))),
      AccessLog(id: '2', doorId: '3', doorName: 'Lobby Door', openedBy: 'You', openedAt: now.subtract(const Duration(hours: 5))),
      AccessLog(id: '3', doorId: '5', doorName: 'Parking Garage', openedBy: 'Sarah (Guest)', openedAt: now.subtract(const Duration(days: 1))),
      AccessLog(id: '4', doorId: '2', doorName: 'Pool Gate', openedBy: 'You', openedAt: now.subtract(const Duration(days: 1, hours: 3))),
      AccessLog(id: '5', doorId: '4', doorName: 'Gym Entrance', openedBy: 'You', openedAt: now.subtract(const Duration(days: 2))),
      AccessLog(id: '6', doorId: '1', doorName: 'Main Gate', openedBy: 'Mike (Guest)', openedAt: now.subtract(const Duration(days: 2, hours: 4))),
    ];
  }
}
