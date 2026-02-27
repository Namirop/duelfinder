import { Router } from "express";
import { notificationsController } from "../controllers/index.js";
import { authenticate } from "../middlewares/index.js";

const router = Router();

// ===========================================
// Routes des notifications (protégées)
// ===========================================

// GET /api/notifications - Mes notifications
router.get("/", authenticate, notificationsController.getNotifications);

// GET /api/notifications/unread-count - Nombre de non lues
router.get("/unread-count", authenticate, notificationsController.getUnreadCount);

// PUT /api/notifications/read-all - Tout marquer comme lu
router.put("/read-all", authenticate, notificationsController.markAllAsRead);

// PUT /api/notifications/:id/read - Marquer comme lu
router.put("/:id/read", authenticate, notificationsController.markAsRead);

// DELETE /api/notifications/:id - Supprimer une notification
router.delete("/:id", authenticate, notificationsController.deleteNotification);

export default router;
