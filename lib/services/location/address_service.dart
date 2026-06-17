import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddressService{
  String currentAddress = '';

  Future<String?> getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final address = [
          place.name,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        currentAddress = address;
        return address;
      }
    } catch (e) {
      print('Error occurred while fetching address: $e');
    }
    return null;  
  }

}