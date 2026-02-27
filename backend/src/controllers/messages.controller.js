/**
 * Controller des messages
 * Gère la messagerie au sein des parties
 */

// GET /api/games/:gameId/messages
const getGameMessages = async (req, res, next) => {
  // TODO: Valider l'ID de la partie
  // TODO: Vérifier que l'utilisateur participe à la partie
  // TODO: Récupérer les messages avec pagination (cursor-based)
  // TODO: Inclure les infos de l'expéditeur
  // TODO: Retourner les messages

  res.status(501).json({ message: "TODO: Implémenter getGameMessages" });
};

// POST /api/games/:gameId/messages
const sendMessage = async (req, res, next) => {
  // TODO: Valider les données (content)
  // TODO: Vérifier que l'utilisateur participe à la partie
  // TODO: Créer le message
  // TODO: Notifier les autres participants (FCM)
  // TODO: Retourner le message créé

  res.status(501).json({ message: "TODO: Implémenter sendMessage" });
};

// DELETE /api/messages/:id
const deleteMessage = async (req, res, next) => {
  // TODO: Valider l'ID du message
  // TODO: Vérifier que l'utilisateur est l'auteur du message
  // TODO: Supprimer le message
  // TODO: Retourner confirmation

  res.status(501).json({ message: "TODO: Implémenter deleteMessage" });
};

export default {
  getGameMessages,
  sendMessage,
  deleteMessage,
};
