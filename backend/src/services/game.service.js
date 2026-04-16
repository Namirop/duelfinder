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
  if (game.status === "CANCELLED") return "CANCELLED";

  const now = new Date();
  const startTime = new Date(game.scheduledAt);
  const endTime = new Date(startTime.getTime() + game.duration * 60 * 1000);

  // Partie terminée (heure de fin passée) → FINISHED
  if (now >= endTime) return "FINISHED";

  // Partie en cours (heure de début passée mais pas finie) → IN_PROGRESS
  if (now >= startTime) return "IN_PROGRESS";

  // Partie pas encore commencée → OPEN ou FULL selon le statut en base
  return game.status;
};

/**
 * Vérifie si un utilisateur peut créer une nouvelle partie (règle anti-spam)
 * Règle : max 1 partie OPEN à la fois
 * @param {string} userId - ID de l'utilisateur
 * @returns {Promise<{canCreate: boolean, reason?: string}>}
 */
const canCreateGame = async (userId) => {
  const now = new Date();
  const openGame = await prisma.game.findFirst({
    where: {
      creatorId: userId,
      status: "OPEN",
      scheduledAt: { gt: now },
    },
  });

  if (openGame) {
    return {
      canCreate: false,
      reason:
        "Vous avez déjà une partie ouverte. Attendez qu'elle soit complète ou annulez-la pour en créer une autre.",
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
        include: {
          user: {
            select: { id: true, username: true, avatar: true },
          },
        },
      },
      _count: {
        select: {
          participations: { where: { status: "PENDING" } },
        },
      },
    },
    orderBy: { createdAt: "desc" },
  });

  return games.map((game) => ({
    ...game,
    effectiveStatus: getEffectiveStatus(game),
    currentPlayers: game.participations.length + 1,
    participants: game.participations.map((p) => p.user),
    pendingCount: game._count.participations,
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
 * Récupère les parties à proximité
 * @param {number} lat - Latitude de l'utilisateur
 * @param {number} lng - Longitude de l'utilisateur
 * @param {number} distanceKm - Rayon de recherche en km (défaut 30)
 * @param {string|null} excludeUserId - ID de l'utilisateur à exclure (ses propres parties)
 * @param {Date|null} dateFrom - Date de début du filtre (null = pas de filtre)
 * @param {Date|null} dateTo - Date de fin du filtre (null = pas de filtre)
 * @param {string|null} gameTypeFilter - Filtrer par type de jeu (null = tous les jeux)
 * @returns {Promise<Array>} Liste des parties à proximité avec statut effectif
 */
const findNearby = async (
  lat,
  lng,
  distanceKm = 30,
  excludeUserId = null,
  dateFrom = null,
  dateTo = null,
  gameTypeFilter = null,
) => {
  // Bounding box pour pré-filtrer (approximation)
  const latDelta = distanceKm / 111; // 1° lat ≈ 111 km
  const lngDelta = distanceKm / (111 * Math.cos((lat * Math.PI) / 180));

  const now = new Date();

  const baseWhereClause = {
    status: { not: "CANCELLED" },
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

  // Filtrer par type de jeu
  if (gameTypeFilter) {
    baseWhereClause.gameType = gameTypeFilter;
  }

  // Définir la plage de dates selon le filtre
  // Si aucun filtre, on affiche toutes les parties à partir d'aujourd'hui
  const startOfToday = new Date(now);
  startOfToday.setHours(0, 0, 0, 0);

  if (dateFrom && dateTo) {
    // Filtre par plage de dates précise
    baseWhereClause.scheduledAt = {
      gte: new Date(dateFrom),
      lte: new Date(dateTo),
    };
  } else if (dateFrom) {
    // Filtre depuis une date (sans fin)
    baseWhereClause.scheduledAt = {
      gte: new Date(dateFrom),
    };
  } else {
    // "Tout" : toutes les parties depuis aujourd'hui
    baseWhereClause.scheduledAt = {
      gte: startOfToday,
    };
  }

  const games = await prisma.game.findMany({
    where: baseWhereClause,
    include: {
      creator: {
        select: { id: true, username: true, avatar: true, badgeLevel: true },
      },
      participations: {
        where: { status: "ACCEPTED" },
        include: {
          user: {
            select: { id: true, username: true, avatar: true },
          },
        },
      },
    },
    orderBy: { scheduledAt: "asc" },
    take: 100,
  });

  // Filtrer par distance exacte et ajouter les infos calculées
  return games
    .map((game) => ({
      ...game,
      effectiveStatus: getEffectiveStatus(game),
      distance: calculateDistance(lat, lng, game.latitude, game.longitude),
      currentPlayers: game.participations.length + 1,
      // Transformer participations en liste de participants (juste les users)
      participants: game.participations.map((p) => p.user),
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

  const currentPlayers = game.participations.length + 1;

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
    ...updatedGame,
    effectiveStatus: getEffectiveStatus(updatedGame),
    currentPlayers: updatedGame.participations.length + 1,
  };
};

export default {
  findByCreator,
  findNearby,
  canCreateGame,
  getEffectiveStatus,
  markAsFull,
  markAsOpen,
  cancelGame,
  finishGame,
  updateGameStatusByPlayers,
};

