/**
 * Service des messages
 */

import prisma from "../config/database.js";
import gameService from "./game.service.js";

const SENDER_SELECT = {
  id: true,
  username: true,
  avatar: true,
};

/**
 * Récupère les 50 derniers messages d'une partie (du plus ancien au plus récent)
 */
const findByGame = async (gameId) => {
  const messages = await prisma.message.findMany({
    where: { gameId },
    orderBy: { createdAt: "desc" },
    take: 50,
    include: { sender: { select: SENDER_SELECT } },
  });
  // Retourne du plus ancien au plus récent (pour affichage chronologique)
  return messages.reverse();
};

/**
 * Crée un message dans une partie
 */
const create = async (senderId, gameId, content) => {
  return prisma.message.create({
    data: { senderId, gameId, content },
    include: { sender: { select: SENDER_SELECT } },
  });
};

/**
 * Met à jour lastReadAt pour le participant qui ouvre le chat
 */
const markRead = async (userId, gameId) => {
  await prisma.participation.updateMany({
    where: { userId, gameId, status: "ACCEPTED" },
    data: { lastReadAt: new Date() },
  });
};

/**
 * Vérifie que l'utilisateur est membre de la partie (créateur ou participant accepté)
 */
const isGameMember = async (userId, gameId) => {
  const game = await prisma.game.findUnique({
    where: { id: gameId },
    select: {
      creatorId: true,
      participations: {
        where: { userId, status: "ACCEPTED" },
        select: { id: true },
      },
    },
  });
  if (!game) return false;
  return game.creatorId === userId || game.participations.length > 0;
};

/**
 * Retourne toutes les conversations de l'utilisateur :
 * parties où il est créateur ou participant accepté, triées par dernier message
 */
const getConversations = async (userId) => {
  // Récupère la liste des conversations masquées par l'utilisateur
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { hiddenConversations: true },
  });
  const hidden = new Set(user?.hiddenConversations ?? []);

  // Récupère les parties concernées
  const games = await prisma.game.findMany({
    where: {
      OR: [
        { creatorId: userId },
        { participations: { some: { userId, status: "ACCEPTED" } } },
      ],
    },
    include: {
      creator: { select: SENDER_SELECT },
      participations: {
        where: { status: "ACCEPTED" },
        include: { user: { select: SENDER_SELECT } },
      },
      messages: {
        orderBy: { createdAt: "desc" },
        take: 1,
        include: { sender: { select: SENDER_SELECT } },
      },
    },
  });

  // Récupère les lastReadAt des participations de l'utilisateur
  const userParticipations = await prisma.participation.findMany({
    where: { userId, status: "ACCEPTED" },
    select: { gameId: true, lastReadAt: true },
  });
  const lastReadMap = new Map(
    userParticipations.map((p) => [p.gameId, p.lastReadAt])
  );

  // Calcule le unreadCount pour chaque partie
  const conversations = await Promise.all(
    games.map(async (game) => {
      const lastMessage = game.messages[0] ?? null;
      const isCreator = game.creatorId === userId;
      let unreadCount = 0;

      if (!isCreator && lastMessage) {
        const lastReadAt = lastReadMap.get(game.id);
        unreadCount = await prisma.message.count({
          where: {
            gameId: game.id,
            senderId: { not: userId },
            ...(lastReadAt ? { createdAt: { gt: lastReadAt } } : {}),
          },
        });
      }

      const effectiveStatus = gameService.getEffectiveStatus(game);

      return {
        gameId: game.id,
        gameType: game.gameType,
        address: game.address,
        scheduledAt: game.scheduledAt,
        status: effectiveStatus,
        creator: game.creator,
        participants: game.participations.map((p) => p.user),
        lastMessage: lastMessage
          ? {
              id: lastMessage.id,
              content: lastMessage.content,
              senderId: lastMessage.senderId,
              senderUsername: lastMessage.sender.username,
              createdAt: lastMessage.createdAt,
            }
          : null,
        unreadCount,
      };
    })
  );

  // Filtrer : conversations masquées par l'utilisateur
  // + conversations archivées (FINISHED/CANCELLED) sans aucun message
  const filtered = conversations.filter((c) => {
    if (hidden.has(c.gameId)) return false;
    const isArchived = c.status === "FINISHED" || c.status === "CANCELLED";
    if (isArchived && !c.lastMessage) return false;
    return true;
  });

  // Tri : plus récent message en premier, puis parties sans message
  return filtered.sort((a, b) => {
    const aDate = a.lastMessage ? new Date(a.lastMessage.createdAt) : new Date(0);
    const bDate = b.lastMessage ? new Date(b.lastMessage.createdAt) : new Date(0);
    return bDate - aDate;
  });
};

/**
 * Masque une conversation archivée pour l'utilisateur
 */
const hideConversation = async (userId, gameId) => {
  await prisma.user.update({
    where: { id: userId },
    data: { hiddenConversations: { push: gameId } },
  });
};

export default { findByGame, create, markRead, isGameMember, getConversations, hideConversation };
