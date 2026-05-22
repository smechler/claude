enum DoorType { gate, door, elevator, garage }

class Door {
  final String id;
  final String name;
  final String location;
  final DoorType type;
  bool isOnline;
  DateTime? lastOpened;

  Door({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    this.isOnline = true,
    this.lastOpened,
  });

  static List<Door> mockDoors() {
    return [
      Door(
        id: '1',
        name: 'Main Gate',
        location: 'Front Entrance',
        type: DoorType.gate,
        lastOpened: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Door(
        id: '2',
        name: 'Pool Gate',
        location: 'Building A, South',
        type: DoorType.gate,
        lastOpened: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Door(
        id: '3',
        name: 'Lobby Door',
        location: 'Building B',
        type: DoorType.door,
        lastOpened: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Door(
        id: '4',
        name: 'Gym Entrance',
        location: 'Level 1',
        type: DoorType.door,
      ),
      Door(
        id: '5',
        name: 'Parking Garage',
        location: 'Underground',
        type: DoorType.garage,
        lastOpened: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Door(
        id: '6',
        name: 'Residents Elevator',
        location: 'Buildings A & B',
        type: DoorType.elevator,
        lastOpened: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];
  }
}
