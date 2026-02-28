/**
 * Controller des participations
 * Gère les inscriptions aux parties
 */

import prisma from "../config/database.js";
import gameService from "../services/game.service.js";

// POST /api/games/:gameId/participations
const requestParticipation = async (req, res, next) => {
  try {
    const { gameId } = req.params;
    const userId = req.user.userId;

    // Vérifier que la partie existe
    const game = await prisma.game.findUnique({
      where: { id: gameId },
      include: {
        participations: {
          where: { status: "ACCEPTED" },
        },
      },
    });

    if (!game) {
      return res.status(404).json({ error: "Partie introuvable" });
    }

    // Vérifier que la partie est ouverte
    const effectiveStatus = gameService.getEffectiveStatus(game);
    if (effectiveStatus !== "OPEN" && effectiveStatus !== "FULL") {
      return res.status(400).json({ error: "Cette partie n'accepte plus de demandes" });
    }

    // Vérifier que l'utilisateur n'est pas le créateur
    if (game.creatorId === userId) {
      return res.status(400).json({ error: "Vous êtes le créateur de cette partie" });
    }

    // Vérifier que l'utilisateur n'est pas déjà inscrit
    const existingParticipation = await prisma.participation.findUnique({
      where: {
        userId_gameId: { userId, gameId },
      },
    });

    if (existingParticipation) {
      return res.status(400).json({ error: "Vous avez déjà une demande pour cette partie" });
    }

    // Créer la participation
    const participation = await prisma.participation.create({
      data: {
        userId,
        gameId,
        status: "PENDING",
      },
      include: {
        user: {
          select: { id: true, username: true, avatar: true },
        },
      },
    });

    // TODO: Notifier le créateur de la partie (PARTICIPATION_REQUEST)

    res.status(201).json(participation);
  } catch (error) {
    next(error);
  }
};

// GET /api/games/:gameId/participations
const getGameParticipations = async (req, res, next) => {
  try {
    const { gameId } = req.params;

    const participations = await prisma.participation.findMany({
      where: { gameId },
      include: {
        user: {
          select: { id: true, username: true, avatar: true, badgeLevel: true },
        },
      },
      orderBy: { createdAt: "asc" },
    });

    res.status(200).json(participations);
  } catch (error) {
    next(error);
  }
};

// PUT /api/participations/:id/accept
const acceptParticipation = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    // Récupérer la participation avec la partie
    const participation = await prisma.participation.findUnique({
      where: { id },
      include: {
        game: {
          include: {
            participations: {
              where: { status: "ACCEPTED" },
            },
          },
        },
      },
    });

    if (!participation) {
      return res.status(404).json({ error: "Demande introuvable" });
    }

    // Vérifier que l'utilisateur est le créateur de la partie
    if (participation.game.creatorId !== userId) {
      return res.status(403).json({ error: "Vous n'êtes pas le créateur de cette partie" });
    }

    // Vérifier que la participation est en attente
    if (participation.status !== "PENDING") {
      return res.status(400).json({ error: "Cette demande a déjà été traitée" });
    }

    // Vérifier qu'il reste de la place
    const currentPlayers = participation.game.participations.length + 1; // +1 créateur
    if (currentPlayers >= participation.game.maxPlayers) {
      return res.status(400).json({ error: "La partie est déjà complète" });
    }

    // Accepter la participation
    const updatedParticipation = await prisma.participation.update({
      where: { id },
      data: {
        status: "ACCEPTED",
        acceptedAt: new Date(),
      },
      include: {
        user: {
          select: { id: true, username: true, avatar: true },
        },
      },
    });

    // Mettre à jour le statut de la partie si nécessaire
    const updatedGame = await gameService.updateGameStatusByPlayers(participation.gameId);

    // TODO: Notifier le participant (PARTICIPATION_ACCEPTED)
    // TODO: Si partie pleine, notifier tous les participants (GAME_FULL)

    res.status(200).json({
      participation: updatedParticipation,
      game: updatedGame,
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/participations/:id/reject
const rejectParticipation = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    // Récupérer la participation
    const participation = await prisma.participation.findUnique({
      where: { id },
      include: { game: true },
    });

    if (!participation) {
      return res.status(404).json({ error: "Demande introuvable" });
    }

    // Vérifier que l'utilisateur est le créateur de la partie
    if (participation.game.creatorId !== userId) {
      return res.status(403).json({ error: "Vous n'êtes pas le créateur de cette partie" });
    }

    // Vérifier que la participation est en attente
    if (participation.status !== "PENDING") {
      return res.status(400).json({ error: "Cette demande a déjà été traitée" });
    }

    // Rejeter la participation
    const updatedParticipation = await prisma.participation.update({
      where: { id },
      data: { status: "REJECTED" },
      include: {
        user: {
          select: { id: true, username: true, avatar: true },
        },
      },
    });

    // TODO: Notifier le participant (PARTICIPATION_REJECTED)

    res.status(200).json(updatedParticipation);
  } catch (error) {
    next(error);
  }
};

// DELETE /api/participations/:id (le participant quitte)
const cancelParticipation = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    // Récupérer la participation
    const participation = await prisma.participation.findUnique({
      where: { id },
      include: { game: true },
    });

    if (!participation) {
      return res.status(404).json({ error: "Participation introuvable" });
    }

    // Vérifier que l'utilisateur est le participant
    if (participation.userId !== userId) {
      return res.status(403).json({ error: "Ce n'est pas votre participation" });
    }

    // Vérifier que la partie n'est pas déjà terminée ou en cours
    const effectiveStatus = gameService.getEffectiveStatus(participation.game);
    if (effectiveStatus === "IN_PROGRESS" || effectiveStatus === "FINISHED") {
      return res.status(400).json({ error: "Impossible de quitter une partie en cours ou terminée" });
    }

    const wasAccepted = participation.status === "ACCEPTED";

    // Supprimer ou marquer comme annulé
    await prisma.participation.update({
      where: { id },
      data: { status: "CANCELLED" },
    });

    // Si le participant était accepté, mettre à jour le statut de la partie
    if (wasAccepted) {
      await gameService.updateGameStatusByPlayers(participation.gameId);
    }

    // TODO: Notifier le créateur

    res.status(200).json({ message: "Participation annulée" });
  } catch (error) {
    next(error);
  }
};

export default {
  requestParticipation,
  getGameParticipations,
  acceptParticipation,
  rejectParticipation,
  cancelParticipation,
};
