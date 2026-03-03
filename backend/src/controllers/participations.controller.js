/**
 * Controller des participations
 * Gère les inscriptions aux parties
 */

import participationService from "../services/participation.service.js";

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
    // TODO: Notifier le créateur de la partie (PARTICIPATION_REQUEST)
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
    // TODO: Notifier le participant (PARTICIPATION_ACCEPTED)
    // TODO: Si partie pleine, notifier tous les participants (GAME_FULL)
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
    // TODO: Notifier le participant (PARTICIPATION_REJECTED)
    res.status(200).json(participation);
  } catch (error) {
    next(error);
  }
};

// DELETE /api/participations/:id (le participant quitte)
const cancelParticipation = async (req, res, next) => {
  try {
    const participation = await participationService.cancel(req.params.id, req.user.userId);
    // TODO: Notifier le créateur
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
