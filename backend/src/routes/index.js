import express from "express";

// ===========================================
// Import des routers modulaires
// ===========================================
import authRoutes from "./auth.routes.js";
import usersRoutes from "./users.routes.js";
import gamesRoutes from "./games.routes.js";
import participationsRoutes from "./participations.routes.js";
import messagesRoutes from "./messages.routes.js";
import notificationsRoutes from "./notifications.routes.js";

const router = express.Router();

// ===========================================
// Montage des routes
// ===========================================
router.use("/auth", authRoutes);
router.use("/users", usersRoutes);
router.use("/games", gamesRoutes);
router.use("/participations", participationsRoutes);
router.use("/messages", messagesRoutes);
router.use("/notifications", notificationsRoutes);

export default router;
