import { Router } from "express";
import { usersController } from "../controllers/index.js";
import { authenticate, uploadAvatar } from "../middlewares/index.js";

const router = Router();

// ===========================================
// Routes utilisateurs (protégées)
// ===========================================

// GET /api/users/me - Mon profil
router.get("/me", authenticate, usersController.getMe);

// PUT /api/users/me - Mettre à jour mon profil
router.put("/me", authenticate, usersController.updateMe);

// PUT /api/users/me/avatar - Upload avatar
router.put("/me/avatar", authenticate, (req, res, next) => {
  uploadAvatar(req, res, (err) => {
    if (err) {
      if (err.code === "LIMIT_FILE_SIZE") {
        return res.status(413).json({ error: "Fichier trop volumineux (max 5 Mo)" });
      }
      return res.status(400).json({ error: err.message });
    }
    next();
  });
}, usersController.uploadAvatar);

// PUT /api/users/me/fcm-token - Mettre à jour mon token FCM
router.put("/me/fcm-token", authenticate, usersController.updateFcmToken);

// PUT /api/users/me/password - Changer le mot de passe
router.put("/me/password", authenticate, usersController.changePassword);

// DELETE /api/users/me - Supprimer mon compte
router.delete("/me", authenticate, usersController.deleteMe);

// GET /api/users/:id - Profil d'un utilisateur (public)
router.get("/:id", usersController.getUserById);

export default router;
