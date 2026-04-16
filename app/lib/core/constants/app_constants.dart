/// Constantes générales de l'application
class AppConstants {
  AppConstants._();

  // Réseau
  static const int connectionTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;
  static const int locationTimeoutSeconds = 15;

  // Jeux
  static const double defaultDistanceKm = 20;
  static const List<int> gameDurationOptions = [30, 60, 90, 120, 180];

  // Messages
  static const int messagePollingSeconds = 5;

  // Recherche
  static const int searchDebounceMs = 450;
}
