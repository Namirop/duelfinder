import { Router } from "express";
import { participationsController } from "../controllers/index.js";
import { authenticate } from "../middlewares/index.js";

const router = Router();

// ===========================================
// Routes des participations (standalone)
// ===========================================

// PUT /api/participations/:id/accept - Accepter une participation
router.put("/:id/accept", authenticate, participationsController.acceptParticipation);

// PUT /api/participations/:id/reject - Refuser une participation
router.put("/:id/reject", authenticate, participationsController.rejectParticipation);

// DELETE /api/participations/:id - Annuler sa participation
router.delete("/:id", authenticate, participationsController.cancelParticipation);

export default router;
