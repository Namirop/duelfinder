/// Constantes liées à l'API
class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://duelfinder-production.up.railway.app/api';

  // Endpoints Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String user = '/auth/me';
  static const String updateUser = '/auth/me/update';

  // Endpoints Games
  static const String existingGames = '/games/existing';
  static const String myGames = '/games/my-games';
  static const String games = '/games';

  // Endpoints Participations
  // Routes nested sous /games/:gameId → ApiConstants.games + '/$gameId/participations'
  // Routes standalone sur :id     → ApiConstants.participations + '/$id/...'
  static const String participations = '/participations';
  static const String myParticipations = '/participations/my';

  // Endpoints Messages
  static const String messages = '/messages';
  static const String conversations = '/messages/conversations';

  // Endpoints Notifications
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/read';

  // Endpoints Users (profil)
  static const String usersMe = '/users/me';
  static const String usersMePassword = '/users/me/password';
}
