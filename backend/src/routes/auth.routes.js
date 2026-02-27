import { Router } from "express";
const router = Router();
import { authController } from "../controllers/index.js";
import { authenticate } from "../middlewares/auth.js";

// ===========================================
// Routes d'authentification (publiques)
// ===========================================

// POST /api/auth/register - Inscription
router.post("/register", authController.register);

// POST /api/auth/login - Connexion
router.post("/login", authController.login);

// POST /api/auth/facebook - Auth via Facebook
router.post("/facebook", authController.facebookAuth);

// POST /api/auth/instagram - Auth via Instagram
router.post("/instagram", authController.instagramAuth);

// POST /api/auth/refresh - Rafraîchir le token
router.post("/refresh", authController.refreshToken);

// GET /api/auth/me - Récupérer l'utilisateur connecté
router.get("/me", authenticate, authController.getMe);

export default router;
