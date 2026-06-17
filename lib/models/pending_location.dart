import 'package:isar/isar.dart';

part 'pending_location.g.dart';

/// Local storage model for every location point waiting to be synced.
/// This is the offline queue for attendance and field tracking.
@collection
class PendingLocation {
  PendingLocation({
    this.id = Isar.autoIncrement,
    required this.employeeId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.timestamp,
    this.synced = false,
    required this.batteryLevel,
    required this.activityType,
  });

  Id id = Isar.autoIncrement;
  String employeeId;
  double latitude;
  double longitude;
  double accuracy;
  double speed;
  DateTime timestamp;
  bool synced;
  int batteryLevel;
  String activityType;

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'timestamp': timestamp.toIso8601String(),
        'batteryLevel': batteryLevel,
        'activityType': activityType,
      };
}
