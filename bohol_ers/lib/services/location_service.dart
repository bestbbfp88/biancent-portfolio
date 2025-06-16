import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LowAccuracyException implements Exception {
  final double accuracy;
  LowAccuracyException(this.accuracy);
  @override
  String toString() => 'Low accuracy: $accuracy meters';
}

class LocationResult {
  final Position position;
  final bool isLowAccuracy;
  LocationResult(this.position, this.isLowAccuracy);
}

class LocationService {

  Future<LocationResult?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

       Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        return LocationResult(position, position.accuracy > 100);
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

    Future<AddressResult> getAddress() async {
      try {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity == ConnectivityResult.none) {
          return AddressResult(address: 'No internet connection');
        }

        final result = await getCurrentLocation(); // should return an object with `position` and `isLowAccuracy`
        if (result == null) {
          return AddressResult(address: 'Location unavailable');
        }

        final position = result.position;

        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}',
        );

        final response = await http.get(url, headers: {
          'User-Agent': 'bohol-emergency-response-app/1.0 (contact: pacatang.biancent@hnu.edu.ph)'
        });

        String address = 'Failed to get address';

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          address = data['display_name'] ?? 'Address not found';
        }

        return AddressResult(
          address: address,
          isLowAccuracy: result.isLowAccuracy,
          accuracy: position.accuracy,
        );
      } catch (e) {
        print('❌ Unexpected error: $e');
        return AddressResult(address: 'Error: ${e.toString()}');
      }
    }

}


class AddressResult {
  final String address;
  final bool isLowAccuracy;
  final double? accuracy;

  AddressResult({
    required this.address,
    this.isLowAccuracy = false,
    this.accuracy,
  });
}
