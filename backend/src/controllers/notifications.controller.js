/**
 * Controller des notifications
 */

import prisma from "../config/database.js";

// GET /api/notifications
const getNotifications = async (req, res, next) => {
  try {
    const notifications = await prisma.notification.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: "desc" },
    });
    res.json(notifications);
  } catch (err) {
    next(err);
  }
};

// GET /api/notifications/unread-count
const getUnreadCount = async (req, res, next) => {
  try {
    const count = await prisma.notification.count({
      where: { userId: req.user.id, read: false },
    });
    res.json({ count });
  } catch (err) {
    next(err);
  }
};

// PUT /api/notifications/read-all
const markAllAsRead = async (req, res, next) => {
  try {
    const result = await prisma.notification.updateMany({
      where: { userId: req.user.id, read: false },
      data: { read: true },
    });
    res.json({ updated: result.count });
  } catch (err) {
    next(err);
  }
};

// PUT /api/notifications/:id/read
const markAsRead = async (req, res, next) => {
  try {
    const notif = await prisma.notification.findFirst({
      where: { id: req.params.id, userId: req.user.id },
    });
    if (!notif) return res.status(404).json({ error: "Notification non trouvée" });

    const updated = await prisma.notification.update({
      where: { id: req.params.id },
      data: { read: true },
    });
    res.json(updated);
  } catch (err) {
    next(err);
  }
};

// DELETE /api/notifications/:id
const deleteNotification = async (req, res, next) => {
  try {
    const notif = await prisma.notification.findFirst({
      where: { id: req.params.id, userId: req.user.id },
    });
    if (!notif) return res.status(404).json({ error: "Notification non trouvée" });

    await prisma.notification.delete({ where: { id: req.params.id } });
    res.status(204).send();
  } catch (err) {
    next(err);
  }
};

export default {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  deleteNotification,
};
