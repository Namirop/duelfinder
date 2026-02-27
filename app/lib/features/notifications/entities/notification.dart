/// Entité métier AppNotification (évite conflit avec dart:html Notification)
/// TODO: Définir les propriétés de la notification
class AppNotification {
  // TODO: Définir les champs métier
  // - id, type, title, body, data, isRead, createdAt

  const AppNotification();

  // TODO: Ajouter les méthodes utilitaires
  // - isRead, icon basé sur le type, etc.
}

/// Types de notifications
enum NotificationType {
  newGame,          // Nouvelle partie à proximité
  gameReminder,     // Rappel d'une partie à venir
  participantJoined, // Quelqu'un a rejoint ma partie
  newMessage,       // Nouveau message
  gameUpdated,      // Modification d'une partie
  gameCancelled,    // Partie annulée
  // TODO: Ajouter d'autres types selon les besoins
}
