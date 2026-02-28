/**
 * Service des parties
 * Contient la logique métier liée aux parties de TCG
 */

import prisma from "../config/database.js";

/**
 * Calcule le statut effectif d'une partie (OPEN, FULL, IN_PROGRESS, FINISHED, CANCELLED)
 * Les statuts IN_PROGRESS et FINISHED sont calculés à la volée selon l'heure actuelle
 * @param {Object} game - La partie avec son statut stocké en base
 * @returns {string} Le statut effectif
 */
const getEffectiveStatus = (game) => {
  // CANCELLED reste CANCELLED
  if (game.status === "CANCELLED") return "CANCELLED";

  // OPEN reste OPEN (pas encore remplie)
  if (game.status === "OPEN") return "OPEN";

  // Ici status = FULL, on calcule selon l'heure
  const now = new Date();
  const startTime = new Date(game.scheduledAt);
  const endTime = new Date(startTime.getTime() + game.duration * 60 * 1000);

  if (now >= endTime) return "FINISHED";
  if (now >= startTime) return "IN_PROGRESS";
  return "FULL";
};

/**
 * Ajoute le statut effectif à une partie
 * @param {Object} game - La partie
 * @returns {Object} La partie avec effectiveStatus
 */
const withEffectiveStatus = (game) => ({
  ...game,
  effectiveStatus: getEffectiveStatus(game),
});

/**
 * Vérifie si un utilisateur peut créer une nouvelle partie (règle anti-spam)
 * Règle : max 1 partie avec wasFilledOnce=false par jour
 * @param {string} userId - ID de l'utilisateur
 * @param {Date} date - Date de la partie à créer
 * @returns {Promise<{canCreate: boolean, reason?: string}>}
 */
const canCreateGame = async (userId, date) => {
  const targetDate = new Date(date);
  const startOfDay = new Date(targetDate);
  startOfDay.setHours(0, 0, 0, 0);
  const endOfDay = new Date(targetDate);
  endOfDay.setHours(23, 59, 59, 999);

  // Chercher une partie non remplie ce jour-là
  const unfilledGame = await prisma.game.findFirst({
    where: {
      creatorId: userId,
      wasFilledOnce: false,
      status: { not: "CANCELLED" },
      scheduledAt: {
        gte: startOfDay,
        lte: endOfDay,
      },
    },
  });

  if (unfilledGame) {
    return {
      canCreate: false,
      reason: "Vous avez déjà une partie en attente de joueurs ce jour-là. Attendez qu'elle soit complète pour en créer une autre.",
    };
  }

  return { canCreate: true };
};

/**
 * Récupère les parties créées par un utilisateur
 * @param {string} userId - ID de l'utilisateur
 * @returns {Promise<Array>} Liste des parties créées avec statut effectif
 */
const findByCreator = async (userId) => {
  const games = await prisma.game.findMany({
    where: { creatorId: userId },
    include: {
      creator: {
        select: { id: true, username: true, avatar: true },
      },
      participations: {
        where: { status: "ACCEPTED" },
        select: { userId: true },
      },
    },
    orderBy: { createdAt: "desc" },
  });

  return games.map((game) => ({
    ...withEffectiveStatus(game),
    currentPlayers: game.participations.length + 1, // +1 pour le créateur
  }));
};

/**
 * Calcule la distance entre deux points en km (formule Haversine)
 */
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Rayon de la Terre en km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

/**
 * Récupère les parties à proximité pour un jour donné
 * Règle d'affichage : parties du jour, sinon premier jour avec des parties
 * @param {number} lat - Latitude de l'utilisateur
 * @param {number} lng - Longitude de l'utilisateur
 * @param {number} distanceKm - Rayon de recherche en km (défaut 30)
 * @param {string|null} excludeUserId - ID de l'utilisateur à exclure (ses propres parties)
 * @param {Date|null} targetDate - Date cible (défaut aujourd'hui)
 * @returns {Promise<Array>} Liste des parties à proximité avec statut effectif
 */
const findNearby = async (lat, lng, distanceKm = 30, excludeUserId = null, targetDate = null) => {
  // Bounding box pour pré-filtrer (approximation)
  const latDelta = distanceKm / 111; // 1° lat ≈ 111 km
  const lngDelta = distanceKm / (111 * Math.cos((lat * Math.PI) / 180));

  // Définir la plage de dates
  const now = new Date();
  const startOfToday = new Date(now);
  startOfToday.setHours(0, 0, 0, 0);
  const endOfToday = new Date(now);
  endOfToday.setHours(23, 59, 59, 999);

  const baseWhereClause = {
    latitude: {
      gte: lat - latDelta,
      lte: lat + latDelta,
    },
    longitude: {
      gte: lng - lngDelta,
      lte: lng + lngDelta,
    },
  };

  // Exclure les parties de l'utilisateur connecté
  if (excludeUserId) {
    baseWhereClause.creatorId = { not: excludeUserId };
  }

  // D'abord chercher les parties d'aujourd'hui
  let games = await prisma.game.findMany({
    where: {
      ...baseWhereClause,
      scheduledAt: {
        gte: startOfToday,
        lte: endOfToday,
      },
    },
    include: {
      creator: {
        select: { id: true, username: true, avatar: true, badgeLevel: true },
      },
      participations: {
        where: { status: "ACCEPTED" },
        select: { userId: true },
      },
    },
    orderBy: { scheduledAt: "asc" },
  });

  // Si pas de parties aujourd'hui, chercher le prochain jour avec des parties
  if (games.length === 0) {
    games = await prisma.game.findMany({
      where: {
        ...baseWhereClause,
        scheduledAt: {
          gt: endOfToday,
        },
        status: { not: "CANCELLED" },
      },
      include: {
        creator: {
          select: { id: true, username: true, avatar: true, badgeLevel: true },
        },
        participations: {
          where: { status: "ACCEPTED" },
          select: { userId: true },
        },
      },
      orderBy: { scheduledAt: "asc" },
      take: 50, // Limiter pour perf
    });

    // Grouper par jour et prendre seulement le premier jour
    if (games.length > 0) {
      const firstGameDate = new Date(games[0].scheduledAt);
      const startOfFirstDay = new Date(firstGameDate);
      startOfFirstDay.setHours(0, 0, 0, 0);
      const endOfFirstDay = new Date(firstGameDate);
      endOfFirstDay.setHours(23, 59, 59, 999);

      games = games.filter((game) => {
        const gameDate = new Date(game.scheduledAt);
        return gameDate >= startOfFirstDay && gameDate <= endOfFirstDay;
      });
    }
  }

  // Filtrer par distance exacte et ajouter les infos calculées
  return games
    .map((game) => ({
      ...withEffectiveStatus(game),
      distance: calculateDistance(lat, lng, game.latitude, game.longitude),
      currentPlayers: game.participations.length + 1, // +1 pour le créateur
    }))
    .filter((game) => game.distance <= distanceKm)
    .sort((a, b) => a.distance - b.distance);
};

/**
 * Met à jour le statut d'une partie à FULL et marque wasFilledOnce
 * @param {string} gameId - ID de la partie
 * @returns {Promise<Object>} La partie mise à jour
 */
const markAsFull = async (gameId) => {
  return prisma.game.update({
    where: { id: gameId },
    data: {
      status: "FULL",
      wasFilledOnce: true,
    },
  });
};

/**
 * Remet une partie à OPEN (quand quelqu'un quitte une partie FULL)
 * Note: wasFilledOnce reste true
 * @param {string} gameId - ID de la partie
 * @returns {Promise<Object>} La partie mise à jour
 */
const markAsOpen = async (gameId) => {
  return prisma.game.update({
    where: { id: gameId },
    data: {
      status: "OPEN",
    },
  });
};

/**
 * Annule une partie
 * @param {string} gameId - ID de la partie
 * @returns {Promise<Object>} La partie mise à jour
 */
const cancelGame = async (gameId) => {
  return prisma.game.update({
    where: { id: gameId },
    data: {
      status: "CANCELLED",
    },
  });
};

/**
 * Marque une partie comme terminée et incrémente totalGamesPlayed pour tous les participants
 * @param {string} gameId - ID de la partie
 * @returns {Promise<Object>} La partie mise à jour
 */
const finishGame = async (gameId) => {
  // Récupérer la partie avec ses participants acceptés
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
    throw new Error("Partie introuvable");
  }

  // Liste des IDs à incrémenter (créateur + participants acceptés)
  const userIds = [game.creatorId, ...game.participations.map((p) => p.userId)];

  // Transaction pour mettre à jour tout d'un coup
  await prisma.$transaction([
    // Marquer la partie comme terminée
    prisma.game.update({
      where: { id: gameId },
      data: { finishedAt: new Date() },
    }),
    // Incrémenter totalGamesPlayed pour chaque participant
    prisma.user.updateMany({
      where: { id: { in: userIds } },
      data: { totalGamesPlayed: { increment: 1 } },
    }),
  ]);

  return prisma.game.findUnique({
    where: { id: gameId },
    include: {
      creator: {
        select: { id: true, username: true, avatar: true },
      },
    },
  });
};

/**
 * Vérifie et met à jour le statut d'une partie selon le nombre de joueurs
 * @param {string} gameId - ID de la partie
 * @returns {Promise<Object>} La partie mise à jour avec statut effectif
 */
const updateGameStatusByPlayers = async (gameId) => {
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
    throw new Error("Partie introuvable");
  }

  const currentPlayers = game.participations.length + 1; // +1 pour le créateur

  if (currentPlayers >= game.maxPlayers && game.status === "OPEN") {
    // Partie pleine
    await markAsFull(gameId);
  } else if (currentPlayers < game.maxPlayers && game.status === "FULL") {
    // Place libérée
    await markAsOpen(gameId);
  }

  // Retourner la partie mise à jour
  const updatedGame = await prisma.game.findUnique({
    where: { id: gameId },
    include: {
      creator: {
        select: { id: true, username: true, avatar: true },
      },
      participations: {
        where: { status: "ACCEPTED" },
        select: { userId: true },
      },
    },
  });

  return {
    ...withEffectiveStatus(updatedGame),
    currentPlayers: updatedGame.participations.length + 1,
  };
};

export default {
  findByCreator,
  findNearby,
  canCreateGame,
  getEffectiveStatus,
  withEffectiveStatus,
  markAsFull,
  markAsOpen,
  cancelGame,
  finishGame,
  updateGameStatusByPlayers,
};
