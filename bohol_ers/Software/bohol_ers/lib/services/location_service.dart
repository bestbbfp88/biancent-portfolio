import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Fetch the current location of the user.
  Future<Position> _getCurrentLocation() async {
    // Check if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    // Set desired accuracy to high
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // High accuracy
    );
  }

  /// Fetch the address based on the current location.
  Future<String> getAddress() async {
    try {
      // Get the current position.
      Position position = await _getCurrentLocation();

      // Use the position to fetch the address.
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Return the first valid address if available.
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.name}, ${place.locality}, ${place.country}';
      } else {
        return 'Address not found.';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
