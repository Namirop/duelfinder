import { Router } from "express";
import { messagesController } from "../controllers/index.js";
import { authenticate } from "../middlewares/index.js";

const router = Router();

// GET /api/messages/conversations - Toutes mes conversations
router.get("/conversations", authenticate, messagesController.getConversations);

// DELETE /api/messages/:id - Supprimer un message
router.delete("/:id", authenticate, messagesController.deleteMessage);

export default router;
