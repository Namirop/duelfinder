/**
 * Service des participations
 * Contient la logique métier liée aux inscriptions aux parties
 */

import prisma from "../config/database.js";
import gameService from "./game.service.js";

/**
 * Récupère les participations d'un utilisateur (avec les parties associées)
 * @param {string} userId
 * @param {string} [status] - Filtre optionnel par statut
 * @returns {Promise<Array>}
 */
const findByUser = async (userId, status) => {
  const where = { userId };
  if (status) where.status = status;

  const participations = await prisma.participation.findMany({
    where,
    include: {
      game: {
        include: {
          creator: { select: { id: true, username: true, avatar: true } },
          participations: {
            where: { status: "ACCEPTED" },
            include: {
              user: { select: { id: true, username: true, avatar: true } },
            },
          },
        },
      },
    },
    orderBy: { createdAt: "desc" },
  });

  return participations.map((p) => ({
    ...p,
    game: {
      ...p.game,
      effectiveStatus: gameService.getEffectiveStatus(p.game),
      currentPlayers: p.game.participations.length + 1,
      participants: p.game.participations.map((part) => part.user),
    },
  }));
};

/**
 * Récupère les participations d'une partie
 * @param {string} gameId
 * @returns {Promise<Array>}
 */
const findByGame = async (gameId) => {
  return prisma.participation.findMany({
    where: { gameId },
    include: {
      user: {
        select: { id: true, username: true, avatar: true, badgeLevel: true },
      },
    },
    orderBy: { createdAt: "asc" },
  });
};

/**
 * Crée une demande de participation (ou la réactive si annulée/refusée)
 * @param {string} userId
 * @param {string} gameId
 * @returns {Promise<Object>} La participation créée
 * @throws {Error} Si la partie n'existe pas, n'est plus ouverte, ou l'utilisateur ne peut pas demander
 */
const create = async (userId, gameId) => {
  const game = await prisma.game.findUnique({
    where: { id: gameId },
    include: { participations: { where: { status: "ACCEPTED" } } },
  });

  if (!game) {
    const err = new Error("Partie introuvable");
    err.statusCode = 404;
    throw err;
  }

  const effectiveStatus = gameService.getEffectiveStatus(game);
  if (effectiveStatus !== "OPEN" && effectiveStatus !== "FULL") {
    const err = new Error("Cette partie n'accepte plus de demandes");
    err.statusCode = 400;
    throw err;
  }

  if (game.creatorId === userId) {
    const err = new Error("Vous êtes le créateur de cette partie");
    err.statusCode = 400;
    throw err;
  }

  const existing = await prisma.participation.findUnique({
    where: { userId_gameId: { userId, gameId } },
  });

  if (existing) {
    if (existing.status === "CANCELLED" || existing.status === "REJECTED") {
      return prisma.participation.update({
        where: { id: existing.id },
        data: { status: "PENDING", acceptedAt: null },
        include: {
          user: { select: { id: true, username: true, avatar: true } },
        },
      });
    }
    const err = new Error("Vous avez déjà une demande pour cette partie");
    err.statusCode = 400;
    throw err;
  }

  return prisma.participation.create({
    data: { userId, gameId, status: "PENDING" },
    include: { user: { select: { id: true, username: true, avatar: true } } },
  });
};

/**
 * Accepte une demande de participation
 * @param {string} participationId
 * @param {string} requestingUserId - Doit être le créateur de la partie
 * @returns {Promise<{participation: Object, game: Object}>}
 */
const accept = async (participationId, requestingUserId) => {
  const participation = await prisma.participation.findUnique({
    where: { id: participationId },
    include: {
      game: { include: { participations: { where: { status: "ACCEPTED" } } } },
    },
  });

  if (!participation) {
    const err = new Error("Demande introuvable");
    err.statusCode = 404;
    throw err;
  }

  if (participation.game.creatorId !== requestingUserId) {
    const err = new Error("Vous n'êtes pas le créateur de cette partie");
    err.statusCode = 403;
    throw err;
  }

  if (participation.status !== "PENDING") {
    const err = new Error("Cette demande a déjà été traitée");
    err.statusCode = 400;
    throw err;
  }

  const currentPlayers = participation.game.participations.length + 1;
  if (currentPlayers >= participation.game.maxPlayers) {
    const err = new Error("La partie est déjà complète");
    err.statusCode = 400;
    throw err;
  }

  const updatedParticipation = await prisma.participation.update({
    where: { id: participationId },
    data: { status: "ACCEPTED", acceptedAt: new Date() },
    include: { user: { select: { id: true, username: true, avatar: true } } },
  });

  const updatedGame = await gameService.updateGameStatusByPlayers(
    participation.gameId,
  );

  return { participation: updatedParticipation, game: updatedGame };
};

/**
 * Refuse une demande de participation
 * @param {string} participationId
 * @param {string} requestingUserId - Doit être le créateur de la partie
 * @returns {Promise<Object>} La participation mise à jour
 */
const reject = async (participationId, requestingUserId) => {
  const participation = await prisma.participation.findUnique({
    where: { id: participationId },
    include: { game: true },
  });

  if (!participation) {
    const err = new Error("Demande introuvable");
    err.statusCode = 404;
    throw err;
  }

  if (participation.game.creatorId !== requestingUserId) {
    const err = new Error("Vous n'êtes pas le créateur de cette partie");
    err.statusCode = 403;
    throw err;
  }

  if (participation.status !== "PENDING") {
    const err = new Error("Cette demande a déjà été traitée");
    err.statusCode = 400;
    throw err;
  }

  return prisma.participation.update({
    where: { id: participationId },
    data: { status: "REJECTED" },
    include: { user: { select: { id: true, username: true, avatar: true } } },
  });
};

/**
 * Annule une participation (par le participant lui-même)
 * @param {string} participationId
 * @param {string} requestingUserId - Doit être le participant
 * @returns {Promise<Object>} La participation avec status CANCELLED
 */
const cancel = async (participationId, requestingUserId) => {
  const participation = await prisma.participation.findUnique({
    where: { id: participationId },
    include: { game: true },
  });

  if (!participation) {
    const err = new Error("Participation introuvable");
    err.statusCode = 404;
    throw err;
  }

  if (participation.userId !== requestingUserId) {
    const err = new Error("Ce n'est pas votre participation");
    err.statusCode = 403;
    throw err;
  }

  const effectiveStatus = gameService.getEffectiveStatus(participation.game);
  if (effectiveStatus === "IN_PROGRESS" || effectiveStatus === "FINISHED") {
    const err = new Error(
      "Impossible de quitter une partie en cours ou terminée",
    );
    err.statusCode = 400;
    throw err;
  }

  const wasAccepted = participation.status === "ACCEPTED";

  const updated = await prisma.participation.update({
    where: { id: participationId },
    data: { status: "CANCELLED" },
    include: { user: { select: { id: true, username: true, avatar: true } } },
  });

  if (wasAccepted) {
    await gameService.updateGameStatusByPlayers(participation.gameId);
  }

  return updated;
};

export default { create, findByGame, findByUser, accept, reject, cancel };
