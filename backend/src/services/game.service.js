/**
 * Service des parties
 * Contient la logique métier liée aux parties de TCG
 */

import prisma from "../config/database.js";

/**
 * Récupère les parties créées par un utilisateur
 * @param {string} userId - ID de l'utilisateur
 * @returns {Promise<Array>} Liste des parties créées
 */
const findByCreator = async (userId) => {
  return prisma.game.findMany({
    where: { creatorId: userId },
    include: {
      creator: {
        select: { id: true, username: true, avatar: true },
      },
    },
    orderBy: { createdAt: "desc" },
  });
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
 * @returns {Promise<Array>} Liste des parties à proximité
 */
const findNearby = async (lat, lng, distanceKm = 30, excludeUserId = null) => {
  // Bounding box pour pré-filtrer (approximation)
  const latDelta = distanceKm / 111; // 1° lat ≈ 111 km
  const lngDelta = distanceKm / (111 * Math.cos((lat * Math.PI) / 180));

  const whereClause = {
    status: "OPEN",
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
    whereClause.creatorId = { not: excludeUserId };
  }

  const games = await prisma.game.findMany({
    where: whereClause,
    include: {
      creator: {
        select: { id: true, username: true, avatar: true },
      },
    },
    orderBy: { scheduledAt: "asc" },
  });

  // Filtrer par distance exacte et ajouter la distance à chaque partie
  return games
    .map((game) => ({
      ...game,
      distance: calculateDistance(lat, lng, game.latitude, game.longitude),
    }))
    .filter((game) => game.distance <= distanceKm)
    .sort((a, b) => a.distance - b.distance);
};

export default {
  findByCreator,
  findNearby,
};
