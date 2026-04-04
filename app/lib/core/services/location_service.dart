import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Vérifie et demande les permissions de localisation
  Future<bool> requestPermission() async {
    // est-ce que le GPS du téléphone est activé ?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    // est-ce que cette APP a le droit d’utiliser la localisation ?
    LocationPermission permission = await Geolocator.checkPermission();
    // si refusé → popup
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    // si deniedForever (refusé + coché "ne plus demander") → PAS de popup
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // si déjà accepté → PAS de popup
    return true;
  }

  /// Récupère la position actuelle (ne demande PAS la permission — appeler requestPermission() avant)
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Calcule la distance entre deux points en km
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000;
  }
}
