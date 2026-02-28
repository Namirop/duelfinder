import { Router } from "express";
import {
  gamesController,
  participationsController,
  messagesController,
} from "../controllers/index.js";
import {
  authenticate,
  optionalAuth,
  createGameLimiter,
  participationLimiter,
} from "../middlewares/index.js";

const router = Router();

// GET /api/games/existing - Liste des parties (filtrable)
router.get("/existing", optionalAuth, gamesController.getExistingGames);

// GET /api/games/my-games - Mes parties
router.get("/my-games", authenticate, gamesController.getMyGames);

// GET /api/games/:id - Détails d'une partie
router.get("/:id", optionalAuth, gamesController.getGameById);

// POST /api/games - Créer une partie (5 max par heure)
router.post("/", authenticate, createGameLimiter, gamesController.createGame);

// PUT /api/games/:id - Modifier une partie
router.put("/:id", authenticate, gamesController.updateGame);

// DELETE /api/games/:id - Supprimer une partie
router.delete("/:id", authenticate, gamesController.deleteGame);

// ===========================================
// Routes des participations (nested)
// ===========================================

// GET /api/games/:gameId/participations - Participants d'une partie
router.get(
  "/:gameId/participations",
  authenticate,
  participationsController.getGameParticipations,
);

// POST /api/games/:gameId/participations - Demander à participer (20 max par heure)
router.post(
  "/:gameId/participations",
  authenticate,
  participationLimiter,
  participationsController.requestParticipation,
);

// ===========================================
// Routes des messages (nested)
// ===========================================

// GET /api/games/:gameId/messages - Messages d'une partie
router.get(
  "/:gameId/messages",
  authenticate,
  messagesController.getGameMessages,
);

// POST /api/games/:gameId/messages - Envoyer un message
router.post("/:gameId/messages", authenticate, messagesController.sendMessage);

export default router;
