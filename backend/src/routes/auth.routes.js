import { Router } from "express";
const router = Router();
import { authController } from "../controllers/index.js";
import { authenticate, authLimiter } from "../middlewares/index.js";

// ===========================================
// Routes d'authentification (publiques)
// Rate limit strict : 10 tentatives / 15 min
// ===========================================

// POST /api/auth/register - Inscription
router.post("/register", authLimiter, authController.register);

// POST /api/auth/login - Connexion
router.post("/login", authLimiter, authController.login);

// POST /api/auth/facebook - Auth via Facebook
router.post("/facebook", authLimiter, authController.facebookAuth);

// POST /api/auth/instagram - Auth via Instagram
router.post("/instagram", authLimiter, authController.instagramAuth);

// POST /api/auth/refresh - Rafraîchir le token
router.post("/refresh", authController.refreshToken);

// GET /api/auth/me - Récupérer l'utilisateur connecté
router.get("/me", authenticate, authController.getMe);

export default router;
