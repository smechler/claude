import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/door.dart';
import '../models/access_log.dart';
import '../models/guest.dart';
import '../models/scheduled_access.dart';

class AppProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  List<Door> _doors = [];
  List<AccessLog> _logs = [];
  List<Guest> _guests = [];
  List<ScheduledAccess> _schedules = [];

  bool _useSlideToOpen = false;
  bool _notificationsEnabled = true;
  bool _hapticFeedback = true;
  String _communityName = 'Oakwood Residences';
  String _userName = 'Alex';
  String _unitNumber = '4B';

  List<Door> get doors => _doors;
  List<AccessLog> get logs => _logs;
  List<Guest> get guests => _guests;
  List<ScheduledAccess> get schedules => _schedules;

  bool get useSlideToOpen => _useSlideToOpen;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get hapticFeedback => _hapticFeedback;
  String get communityName => _communityName;
  String get userName => _userName;
  String get unitNumber => _unitNumber;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    _loadMockData();
  }

  void _loadSettings() {
    _useSlideToOpen = _prefs.getBool('useSlideToOpen') ?? false;
    _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    _hapticFeedback = _prefs.getBool('hapticFeedback') ?? true;
    _communityName = _prefs.getString('communityName') ?? 'Oakwood Residences';
    _userName = _prefs.getString('userName') ?? 'Alex';
    _unitNumber = _prefs.getString('unitNumber') ?? '4B';
  }

  void _loadMockData() {
    _doors = Door.mockDoors();
    _logs = AccessLog.mockLogs();
    _guests = Guest.mockGuests();
    _schedules = ScheduledAccess.mockSchedules();
  }

  Future<void> openDoor(Door door) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final log = AccessLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doorId: door.id,
      doorName: door.name,
      openedBy: 'You',
      openedAt: DateTime.now(),
    );
    _logs.insert(0, log);
    door.lastOpened = DateTime.now();
    notifyListeners();
  }

  Future<void> setUseSlideToOpen(bool value) async {
    _useSlideToOpen = value;
    await _prefs.setBool('useSlideToOpen', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    await _prefs.setBool('hapticFeedback', value);
    notifyListeners();
  }

  Future<void> setCommunityName(String value) async {
    _communityName = value;
    await _prefs.setString('communityName', value);
    notifyListeners();
  }

  Future<void> setUserName(String value) async {
    _userName = value;
    await _prefs.setString('userName', value);
    notifyListeners();
  }

  Future<void> setUnitNumber(String value) async {
    _unitNumber = value;
    await _prefs.setString('unitNumber', value);
    notifyListeners();
  }

  void addGuest(Guest guest) {
    _guests.insert(0, guest);
    notifyListeners();
  }

  void removeGuest(String guestId) {
    _guests.removeWhere((g) => g.id == guestId);
    notifyListeners();
  }

  void toggleGuestActive(String guestId) {
    final idx = _guests.indexWhere((g) => g.id == guestId);
    if (idx != -1) {
      _guests[idx].isActive = !_guests[idx].isActive;
      notifyListeners();
    }
  }

  void addSchedule(ScheduledAccess schedule) {
    _schedules.insert(0, schedule);
    notifyListeners();
  }

  void removeSchedule(String scheduleId) {
    _schedules.removeWhere((s) => s.id == scheduleId);
    notifyListeners();
  }

  void toggleScheduleActive(String scheduleId) {
    final idx = _schedules.indexWhere((s) => s.id == scheduleId);
    if (idx != -1) {
      _schedules[idx].isActive = !_schedules[idx].isActive;
      notifyListeners();
    }
  }
}
