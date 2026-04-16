/**
 * Controller des parties (Games)
 * Gère la création et la gestion des parties de TCG
 */
import prisma from "../config/database.js";
import gameService from "../services/game.service.js";
import notificationService from "../services/notification.service.js";
import { GAME_TYPE_LABELS } from "../constants.js";

// GET /api/games/existing
const getExistingGames = async (req, res, next) => {
  try {
    const { lat, lng, distance, dateFrom, dateTo, gameType } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: "Latitude et longitude requises" });
    }

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    const distanceKm = distance ? parseFloat(distance) : 30;
    const dateFromFilter = dateFrom || null;
    const dateToFilter = dateTo || null;
    const gameTypeFilter = gameType || null;

    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json({ error: "Coordonnées invalides" });
    }

    const excludeUserId = req.user?.userId || null;

    const games = await gameService.findNearby(
      latitude,
      longitude,
      distanceKm,
      excludeUserId,
      dateFromFilter,
      dateToFilter,
      gameTypeFilter,
    );

    res.status(200).json(games);
  } catch (error) {
    next(error);
  }
};

// GET /api/games/my-games
const getMyGames = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const games = await gameService.findByCreator(userId);
    res.status(200).json(games);
  } catch (error) {
    next(error);
  }
};

// POST /api/games
const createGame = async (req, res, next) => {
  try {
    const {
      gameType,
      description,
      address,
      latitude,
      longitude,
      scheduledAt,
      duration,
      maxPlayers,
    } = req.body;

    if (!gameType) {
      return res.status(400).json({ error: "TCG non choisi" });
    }

    if (!address) {
      return res.status(400).json({ error: "Adresse non indiquée" });
    }

    if (!latitude || !longitude) {
      return res
        .status(400)
        .json({ error: "Coordonnées du lieu non récupérées" });
    }

    if (!scheduledAt) {
      return res.status(400).json({ error: "Horaire non défini" });
    }

    if (!duration) {
      return res.status(400).json({ error: "Durée de la partie non définie" });
    }

    if (!maxPlayers) {
      return res.status(400).json({ error: "Maximum de joueurs non défini" });
    }

    // Vérifier la règle anti-spam
    const { canCreate, reason } = await gameService.canCreateGame(
      req.user.userId,
    );

    if (!canCreate) {
      return res.status(429).json({ error: reason });
    }

    const game = await prisma.game.create({
      data: {
        gameType,
        description: description || null,
        address,
        latitude,
        longitude,
        scheduledAt: new Date(scheduledAt),
        duration,
        maxPlayers,
        creatorId: req.user.userId,
      },
      include: {
        creator: {
          select: { id: true, username: true, avatar: true },
        },
      },
    });

    res.status(201).json({
      ...game,
      effectiveStatus: gameService.getEffectiveStatus(game),
      currentPlayers: 1,
      participants: [],
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/games/:gameId (annulation)
const deleteGame = async (req, res, next) => {
  try {
    const { gameId } = req.params;
    const userId = req.user.userId;

    const game = await prisma.game.findUnique({
      where: { id: gameId },
      include: {
        participations: {
          where: { status: "ACCEPTED" },
          select: { userId: true },
        },
      },
    });

    if (!game) {
      return res.status(404).json({ error: "Partie introuvable" });
    }

    if (game.creatorId !== userId) {
      return res
        .status(403)
        .json({ error: "Vous n'êtes pas le créateur de cette partie" });
    }

    if (game.status === "CANCELLED") {
      return res.status(400).json({ error: "Cette partie est déjà annulée" });
    }

    await gameService.cancelGame(gameId);

    // Notifier tous les participants acceptés
    const participantIds = game.participations.map((p) => p.userId);
    if (participantIds.length > 0) {
      const label = GAME_TYPE_LABELS[game.gameType] ?? game.gameType;
      notificationService.sendToUsers(participantIds, {
        type: "GAME_CANCELLED",
        title: "Partie annulée",
        body: `La partie de ${label} a été annulée par le créateur`,
        data: { gameId },
      });
    }

    res.status(200).json({ message: "Partie annulée" });
  } catch (error) {
    next(error);
  }
};

export default {
  getExistingGames,
  getMyGames,
  createGame,
  deleteGame,
};
