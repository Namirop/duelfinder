import { Router } from "express";
import { usersController } from "../controllers/index.js";
import { authenticate } from "../middlewares/index.js";

const router = Router();

// ===========================================
// Routes utilisateurs (protégées)
// ===========================================

// GET /api/users/me - Mon profil
router.get("/me", authenticate, usersController.getMe);

// PUT /api/users/me - Mettre à jour mon profil
router.put("/me", authenticate, usersController.updateMe);

// PUT /api/users/me/fcm-token - Mettre à jour mon token FCM
router.put("/me/fcm-token", authenticate, usersController.updateFcmToken);

// PUT /api/users/me/password - Changer le mot de passe
router.put("/me/password", authenticate, usersController.changePassword);

// DELETE /api/users/me - Supprimer mon compte
router.delete("/me", authenticate, usersController.deleteMe);

// GET /api/users/:id - Profil d'un utilisateur (public)
router.get("/:id", usersController.getUserById);

export default router;
