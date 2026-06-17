import 'package:dio/dio.dart';
import 'package:hr_app/models/pending_location.dart';

/// Repository layer for remote sync operations.
class LocationRepository {
  LocationRepository({Dio? dio}) : _dio = dio ?? Dio(_defaultOptions);

  static final _defaultOptions = BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final Dio _dio;

  Future<void> syncPendingLocations(List<PendingLocation> locations) async {
    if (locations.isEmpty) {
      return;
    }

    final body = {
      'locations': locations.map((location) => location.toJson()).toList(),
    };

    final response = await _dio.post('/attendance/v1/locations/bulk', data: body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Location sync failed with status: ${response.statusCode}');
    }
  }
}
