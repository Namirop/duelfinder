/// Constantes générales de l'application
class AppConstants {
  AppConstants._();

  static const String appName = 'TCG Matchmaker';
  static const String appVersion = '1.0.0';

  // TODO: Ajouter d'autres constantes selon les besoins
  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Cache
  static const int cacheMaxAge = 7; // jours
}
