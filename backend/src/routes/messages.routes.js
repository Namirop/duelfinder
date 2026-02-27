import { Router } from "express";
import { messagesController } from "../controllers/index.js";
import { authenticate } from "../middlewares/index.js";

const router = Router();

// ===========================================
// Routes des messages (standalone)
// ===========================================

// DELETE /api/messages/:id - Supprimer un message
router.delete("/:id", authenticate, messagesController.deleteMessage);

export default router;
