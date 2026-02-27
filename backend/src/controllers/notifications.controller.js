/**
 * Controller des notifications
 * Gère les notifications push et l'historique
 */

// GET /api/notifications
const getNotifications = async (req, res, next) => {
  // TODO: Récupérer les notifications de l'utilisateur connecté
  // TODO: Appliquer pagination
  // TODO: Trier par date décroissante
  // TODO: Retourner les notifications

  res.status(501).json({ message: 'TODO: Implémenter getNotifications' });
};

// GET /api/notifications/unread-count
const getUnreadCount = async (req, res, next) => {
  // TODO: Compter les notifications non lues
  // TODO: Retourner le compteur

  res.status(501).json({ message: 'TODO: Implémenter getUnreadCount' });
};

// PUT /api/notifications/:id/read
const markAsRead = async (req, res, next) => {
  // TODO: Valider l'ID de la notification
  // TODO: Vérifier que la notification appartient à l'utilisateur
  // TODO: Marquer comme lue
  // TODO: Retourner la notification mise à jour

  res.status(501).json({ message: 'TODO: Implémenter markAsRead' });
};

// PUT /api/notifications/read-all
const markAllAsRead = async (req, res, next) => {
  // TODO: Marquer toutes les notifications de l'utilisateur comme lues
  // TODO: Retourner confirmation avec le nombre de notifications mises à jour

  res.status(501).json({ message: 'TODO: Implémenter markAllAsRead' });
};

// DELETE /api/notifications/:id
const deleteNotification = async (req, res, next) => {
  // TODO: Valider l'ID
  // TODO: Vérifier que la notification appartient à l'utilisateur
  // TODO: Supprimer la notification
  // TODO: Retourner confirmation

  res.status(501).json({ message: 'TODO: Implémenter deleteNotification' });
};

export default {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  deleteNotification,
};
