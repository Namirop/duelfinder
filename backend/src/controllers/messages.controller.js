/**
 * Controller des messages
 */

import messageService from "../services/message.service.js";
import notificationService from "../services/notification.service.js";
import prisma from "../config/database.js";
import { GAME_TYPE_LABELS } from "../constants.js";

// GET /api/messages/conversations
const getConversations = async (req, res, next) => {
  try {
    const conversations = await messageService.getConversations(req.user.userId);
    res.status(200).json(conversations);
  } catch (error) {
    next(error);
  }
};

// GET /api/games/:gameId/messages
const getGameMessages = async (req, res, next) => {
  try {
    const { gameId } = req.params;
    const isMember = await messageService.isGameMember(req.user.userId, gameId);
    if (!isMember) {
      return res.status(403).json({ error: "Accès refusé à cette partie" });
    }
    const messages = await messageService.findByGame(gameId);
    res.status(200).json(messages);
  } catch (error) {
    next(error);
  }
};

// POST /api/games/:gameId/messages
const sendMessage = async (req, res, next) => {
  try {
    const { gameId } = req.params;
    const { content } = req.body;

    if (!content || typeof content !== "string" || content.trim().length === 0) {
      return res.status(400).json({ error: "Le message ne peut pas être vide" });
    }
    if (content.trim().length > 1000) {
      return res.status(400).json({ error: "Message trop long (max 1000 caractères)" });
    }

    const isMember = await messageService.isGameMember(req.user.userId, gameId);
    if (!isMember) {
      return res.status(403).json({ error: "Accès refusé à cette partie" });
    }

    const message = await messageService.create(
      req.user.userId,
      gameId,
      content.trim()
    );

    // Notifier les autres membres de la partie
    const game = await prisma.game.findUnique({
      where: { id: gameId },
      select: {
        creatorId: true,
        gameType: true,
        participations: {
          where: { status: "ACCEPTED" },
          select: { userId: true },
        },
      },
    });

    if (game) {
      const label = GAME_TYPE_LABELS[game.gameType] ?? game.gameType;
      const allMemberIds = [
        game.creatorId,
        ...game.participations.map((p) => p.userId),
      ];
      const otherMemberIds = allMemberIds.filter(
        (id) => id !== req.user.userId
      );

      if (otherMemberIds.length > 0) {
        notificationService.sendToUsers(otherMemberIds, {
          type: "NEW_MESSAGE",
          title: `Nouveau message — ${label}`,
          body: `${message.sender.username} : ${content.trim().substring(0, 60)}`,
          data: { gameId },
        });
      }
    }

    res.status(201).json(message);
  } catch (error) {
    next(error);
  }
};

// PUT /api/games/:gameId/messages/read
const markRead = async (req, res, next) => {
  try {
    const { gameId } = req.params;
    await messageService.markRead(req.user.userId, gameId);
    res.status(200).json({ ok: true });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/messages/:id
const deleteMessage = async (req, res, next) => {
  try {
    const message = await prisma.message.findUnique({
      where: { id: req.params.id },
    });
    if (!message) {
      return res.status(404).json({ error: "Message introuvable" });
    }
    if (message.senderId !== req.user.userId) {
      return res.status(403).json({ error: "Non autorisé" });
    }
    await prisma.message.delete({ where: { id: req.params.id } });
    res.status(200).json({ ok: true });
  } catch (error) {
    next(error);
  }
};

export default {
  getConversations,
  getGameMessages,
  sendMessage,
  markRead,
  deleteMessage,
};
