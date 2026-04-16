import { Router } from "express";
import { participationsController } from "../controllers/index.js";
import { authenticate } from "../middlewares/index.js";

const router = Router();

// ===========================================
// Routes des participations (standalone)
// ===========================================

// GET /api/participations/my - Mes participations
router.get("/my", authenticate, participationsController.getMyParticipations);

// PUT /api/participations/:id/accept - Accepter une participation
router.put(
  "/:id/accept",
  authenticate,
  participationsController.acceptParticipation,
);

// PUT /api/participations/:id/reject - Refuser une participation
router.put(
  "/:id/reject",
  authenticate,
  participationsController.rejectParticipation,
);

// PATCH /api/participations/:id/cancel - Annuler sa participation
router.patch(
  "/:id/cancel",
  authenticate,
  participationsController.cancelParticipation,
);

// DELETE /api/participations/:id/permanent - Supprimer définitivement
router.delete(
  "/:id/permanent",
  authenticate,
  participationsController.permanentDeleteParticipation,
);

export default router;
