/// Entité métier Participation
/// TODO: Définir les propriétés de la participation
class Participation {
  // TODO: Définir les champs métier
  // - id, user, game, status, joinedAt

  const Participation();
}

/// Statut de participation
enum ParticipationStatus {
  pending,   // En attente de confirmation
  confirmed, // Confirmé
  cancelled, // Annulé
  completed, // Partie terminée
}
