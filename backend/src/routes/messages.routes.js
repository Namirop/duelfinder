import { Router } from "express";
import { messagesController } from "../controllers/index.js";
import { authenticate } from "../middlewares/index.js";

const router = Router();

// GET /api/messages/conversations - Toutes mes conversations
router.get("/conversations", authenticate, messagesController.getConversations);

// DELETE /api/messages/conversations/:gameId - Masquer une conversation archivée
router.delete("/conversations/:gameId", authenticate, messagesController.hideConversation);

// DELETE /api/messages/:id - Supprimer un message
router.delete("/:id", authenticate, messagesController.deleteMessage);

export default router;
