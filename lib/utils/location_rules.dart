import 'package:geolocator/geolocator.dart';
import 'package:hr_app/models/pending_location.dart';

/// Encapsulates the save rules for offline tracking.
class LocationRules {
  static const double maxAccuracyMeters = 50;
  static const double minDistanceMeters = 50;
  static const Duration staticInterval = Duration(minutes: 5);
  static const Duration walkingInterval = Duration(minutes: 1);
  static const Duration drivingInterval = Duration(seconds: 30);

  static bool isValidAccuracy(Position position) {
    return position.accuracy <= maxAccuracyMeters;
  }

  static bool hasMovedByDistance(Position previous, Position current) {
    final distance = Geolocator.distanceBetween(
      previous.latitude,
      previous.longitude,
      current.latitude,
      current.longitude,
    );
    return distance >= minDistanceMeters;
  }

  static bool shouldSaveLocation({
    required PendingLocation? lastLocation,
    required Position current,
    required DateTime now,
  }) {
    if (!isValidAccuracy(current)) {
      return false;
    }

    if (lastLocation == null) {
      return true;
    }

    final lastPosition = Position(
      longitude: lastLocation.longitude,
      latitude: lastLocation.latitude,
      timestamp: lastLocation.timestamp,
      accuracy: lastLocation.accuracy,
      altitude: 0,
      heading: 0,
      speed: lastLocation.speed,
      speedAccuracy: 0,
      headingAccuracy: 0,
      altitudeAccuracy: 0,
    );

    if (hasMovedByDistance(lastPosition, current)) {
      return true;
    }

    final idleDuration = now.difference(lastLocation.timestamp);
    return idleDuration >= staticInterval;
  }

  static String activityTypeFromSpeed(double speed) {
    if (speed >= 8.0) {
      return 'driving';
    }
    if (speed >= 1.5) {
      return 'walking';
    }
    return 'static';
  }
}
