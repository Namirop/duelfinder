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
    // TODO: Créer automatiquement une participation pour le créateur

    res.status(201).json(game);
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

// DELETE /api/games/:id
const deleteGame = async (req, res, next) => {
  // TODO: Vérifier que l'utilisateur est le créateur
  // TODO: Supprimer la partie (ou la marquer comme annulée)
  // TODO: Notifier les participants
  // TODO: Retourner confirmation

  res.status(501).json({ message: "TODO: Implémenter deleteGame" });
};

export default {
  getExistingGames,
  getGameById,
  createGame,
  updateGame,
  deleteGame,
  getMyGames,
};
