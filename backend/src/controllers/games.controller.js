/**
 * Controller des parties (Games)
 * Gère la création et la gestion des parties de TCG
 */
import prisma from "../config/database.js";
import gameService from "../services/game.service.js";

// GET /api/games/existing
const getExistingGames = async (req, res, next) => {
  try {
    const { lat, lng, distance } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: "Latitude et longitude requises" });
    }

    console.log("DISTANCE : " + distance);

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);
    const distanceKm = distance ? parseFloat(distance) : 30; // Défaut 30km

    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json({ error: "Coordonnées invalides" });
    }

    const excludeUserId = req.user?.userId || null;

    const games = await gameService.findNearby(
      latitude,
      longitude,
      distanceKm,
      excludeUserId,
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

// GET /api/games/:id
const getGameById = async (req, res, next) => {
  // TODO: Valider l'ID
  // TODO: Récupérer la partie avec ses relations (creator, participations)
  // TODO: Retourner les détails de la partie

  res.status(501).json({ message: "TODO: Implémenter getGameById" });
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
      new Date(scheduledAt),
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

    // Retourner avec le statut effectif
    res.status(201).json({
      ...gameService.withEffectiveStatus(game),
      currentPlayers: 1, // Le créateur
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/games/:id
const updateGame = async (req, res, next) => {
  // TODO: Valider les données
  // TODO: Vérifier que l'utilisateur est le créateur
  // TODO: Mettre à jour la partie
  // TODO: Notifier les participants si changement important
  // TODO: Retourner la partie mise à jour

  res.status(501).json({ message: "TODO: Implémenter updateGame" });
};

// DELETE /api/games/:id (annulation)
const deleteGame = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    // Vérifier que la partie existe et appartient à l'utilisateur
    const game = await prisma.game.findUnique({
      where: { id },
      include: {
        participations: {
          where: { status: "ACCEPTED" },
          include: { user: { select: { id: true, fcmToken: true } } },
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

    // Annuler la partie
    await gameService.cancelGame(id);

    // TODO: Notifier les participants (GAME_CANCELLED)

    res.status(200).json({ message: "Partie annulée" });
  } catch (error) {
    next(error);
  }
};

export default {
  getExistingGames,
  getGameById,
  createGame,
  updateGame,
  deleteGame,
  getMyGames,
};
