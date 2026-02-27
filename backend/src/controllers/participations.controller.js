/**
 * Controller des participations
 * Gère les inscriptions aux parties
 */

// POST /api/games/:gameId/participations
const requestParticipation = async (req, res, next) => {
  // TODO: Valider l'ID de la partie
  // TODO: Vérifier que la partie existe et est ouverte
  // TODO: Vérifier que l'utilisateur n'est pas déjà inscrit
  // TODO: Vérifier que la partie n'est pas complète
  // TODO: Créer la participation avec status "pending"
  // TODO: Notifier le créateur de la partie
  // TODO: Retourner la participation créée

  res.status(501).json({ message: 'TODO: Implémenter requestParticipation' });
};

// GET /api/games/:gameId/participations
const getGameParticipations = async (req, res, next) => {
  // TODO: Valider l'ID de la partie
  // TODO: Récupérer toutes les participations de la partie
  // TODO: Inclure les infos utilisateur
  // TODO: Retourner la liste

  res.status(501).json({ message: 'TODO: Implémenter getGameParticipations' });
};

// PUT /api/participations/:id/accept
const acceptParticipation = async (req, res, next) => {
  // TODO: Valider l'ID de la participation
  // TODO: Vérifier que l'utilisateur est le créateur de la partie
  // TODO: Vérifier que la partie n'est pas complète
  // TODO: Mettre à jour le status à "accepted"
  // TODO: Notifier le participant
  // TODO: Retourner la participation mise à jour

  res.status(501).json({ message: 'TODO: Implémenter acceptParticipation' });
};

// PUT /api/participations/:id/reject
const rejectParticipation = async (req, res, next) => {
  // TODO: Valider l'ID de la participation
  // TODO: Vérifier que l'utilisateur est le créateur de la partie
  // TODO: Mettre à jour le status à "rejected"
  // TODO: Notifier le participant
  // TODO: Retourner la participation mise à jour

  res.status(501).json({ message: 'TODO: Implémenter rejectParticipation' });
};

// DELETE /api/participations/:id
const cancelParticipation = async (req, res, next) => {
  // TODO: Valider l'ID de la participation
  // TODO: Vérifier que l'utilisateur est le participant concerné
  // TODO: Mettre à jour le status à "cancelled" ou supprimer
  // TODO: Notifier le créateur de la partie
  // TODO: Retourner confirmation

  res.status(501).json({ message: 'TODO: Implémenter cancelParticipation' });
};

export default {
  requestParticipation,
  getGameParticipations,
  acceptParticipation,
  rejectParticipation,
  cancelParticipation,
};
