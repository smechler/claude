class Guest {
  final String id;
  String name;
  String email;
  List<String> accessibleDoorIds;
  DateTime? expiresAt;
  bool isActive;
  DateTime createdAt;

  Guest({
    required this.id,
    required this.name,
    required this.email,
    required this.accessibleDoorIds,
    this.expiresAt,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  static List<Guest> mockGuests() {
    final now = DateTime.now();
    return [
      Guest(
        id: '1',
        name: 'Sarah Johnson',
        email: 'sarah@example.com',
        accessibleDoorIds: ['1', '3', '5'],
        expiresAt: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Guest(
        id: '2',
        name: 'Mike Chen',
        email: 'mike@example.com',
        accessibleDoorIds: ['1'],
        expiresAt: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      Guest(
        id: '3',
        name: 'Emma Davis',
        email: 'emma@example.com',
        accessibleDoorIds: ['1', '2', '3', '4', '5', '6'],
        isActive: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }
}
