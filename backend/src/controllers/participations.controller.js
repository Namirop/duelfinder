/**
 * Controller des participations
 * Gère les inscriptions aux parties
 */

import prisma from "../config/database.js";
import participationService from "../services/participation.service.js";
import notificationService from "../services/notification.service.js";

const GAME_TYPE_LABELS = {
  POKEMON: "Pokémon",
  ONE_PIECE: "One Piece",
  YUGIOH: "Yu-Gi-Oh!",
  NARUTO: "Naruto",
};

// GET /api/participations/my - Récupérer mes participations
const getMyParticipations = async (req, res, next) => {
  try {
    const { status } = req.query;
    const participations = await participationService.findByUser(
      req.user.userId,
      status,
    );
    res.status(200).json(participations);
  } catch (error) {
    next(error);
  }
};

// GET /api/games/:gameId/participations
const getGameParticipations = async (req, res, next) => {
  try {
    const participations = await participationService.findByGame(
      req.params.gameId,
    );
    res.status(200).json(participations);
  } catch (error) {
    next(error);
  }
};

// POST /api/games/:gameId/participations
const requestParticipation = async (req, res, next) => {
  try {
    const participation = await participationService.create(
      req.user.userId,
      req.params.gameId,
    );

    // Notifier le créateur de la partie
    const game = await prisma.game.findUnique({
      where: { id: req.params.gameId },
      select: { creatorId: true, gameType: true },
    });
    if (game) {
      const label = GAME_TYPE_LABELS[game.gameType] ?? game.gameType;
      notificationService.sendToUser(game.creatorId, {
        type: "PARTICIPATION_REQUEST",
        title: "Nouvelle demande",
        body: `${participation.user.username} veut rejoindre ta partie de ${label}`,
        data: { gameId: req.params.gameId, participationId: participation.id },
      });
    }

    res.status(201).json(participation);
  } catch (error) {
    next(error);
  }
};

// PUT /api/participations/:id/accept
const acceptParticipation = async (req, res, next) => {
  try {
    const result = await participationService.accept(
      req.params.id,
      req.user.userId,
    );
    const { participation, game } = result;
    const label = GAME_TYPE_LABELS[game.gameType] ?? game.gameType;

    // Notifier le joueur accepté
    notificationService.sendToUser(participation.userId, {
      type: "PARTICIPATION_ACCEPTED",
      title: "Demande acceptée !",
      body: `Tu as été accepté dans la partie de ${label}`,
      data: { gameId: game.id },
    });

    // Si la partie est maintenant complète → notifier les autres participants
    if (game.status === "FULL" || game.effectiveStatus === "FULL") {
      const otherIds = (game.participations ?? [])
        .map((p) => p.userId)
        .filter((id) => id !== participation.userId);

      if (otherIds.length > 0) {
        notificationService.sendToUsers(otherIds, {
          type: "GAME_FULL",
          title: "Partie complète !",
          body: `La partie de ${label} est maintenant complète`,
          data: { gameId: game.id },
        });
      }
    }

    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};

// PUT /api/participations/:id/reject
const rejectParticipation = async (req, res, next) => {
  try {
    const participation = await participationService.reject(
      req.params.id,
      req.user.userId,
    );

    // Notifier le joueur refusé
    const game = await prisma.game.findUnique({
      where: { id: participation.gameId },
      select: { gameType: true },
    });
    if (game) {
      const label = GAME_TYPE_LABELS[game.gameType] ?? game.gameType;
      notificationService.sendToUser(participation.userId, {
        type: "PARTICIPATION_REJECTED",
        title: "Demande refusée",
        body: `Ta demande pour la partie de ${label} a été refusée`,
        data: { gameId: participation.gameId },
      });
    }

    res.status(200).json(participation);
  } catch (error) {
    next(error);
  }
};

// DELETE /api/participations/:id (le participant quitte)
const cancelParticipation = async (req, res, next) => {
  try {
    const participation = await participationService.cancel(
      req.params.id,
      req.user.userId,
    );

    // Notifier le créateur de la partie
    const game = await prisma.game.findUnique({
      where: { id: participation.gameId },
      select: { creatorId: true, gameType: true },
    });
    if (game) {
      const label = GAME_TYPE_LABELS[game.gameType] ?? game.gameType;
      notificationService.sendToUser(game.creatorId, {
        type: "PARTICIPATION_CANCELLED",
        title: "Annulation de participation",
        body: `${participation.user.username} a annulé sa participation à ta partie de ${label}`,
        data: { gameId: participation.gameId, participationId: participation.id },
      });
    }

    res.status(200).json(participation);
  } catch (error) {
    next(error);
  }
};

export default {
  getMyParticipations,
  getGameParticipations,
  requestParticipation,
  acceptParticipation,
  rejectParticipation,
  cancelParticipation,
};
