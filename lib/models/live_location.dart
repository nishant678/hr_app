import 'package:isar/isar.dart';

part 'live_location.g.dart';

/// Live location snapshot model. Used to power live monitoring dashboards.
@collection
class LiveLocation {
  LiveLocation({
    this.id = Isar.autoIncrement,
    required this.employeeId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.timestamp,
    required this.activityType,
  });

  Id id = Isar.autoIncrement;
  String employeeId;
  double latitude;
  double longitude;
  double accuracy;
  double speed;
  DateTime timestamp;
  String activityType;
}
