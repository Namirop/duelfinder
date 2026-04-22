/**
 * Utilitaires partagés entre les scripts NPC (seed, cron, cleanup)
 */

export const GAME_TYPES = ["POKEMON", "YUGIOH", "ONE_PIECE", "MAGIC"];

/** Choisit un élément aléatoire dans un tableau */
export function pick(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

/**
 * Décale légèrement les coordonnées (max ~2km par défaut)
 * pour que les parties ne se superposent pas au centre-ville
 */
export function jitter(lat, lng, maxKm = 2) {
  const r = (maxKm / 111) * Math.random();
  const angle = Math.random() * 2 * Math.PI;
  return {
    lat: lat + r * Math.cos(angle),
    lng: lng + (r * Math.sin(angle)) / Math.cos((lat * Math.PI) / 180),
  };
}

/** Génère une date future à daysAhead jours, à une heure réaliste */
export function futureDate(daysAhead) {
  const hours = [10, 11, 14, 15, 16, 17, 18, 19, 20];
  const d = new Date();
  d.setDate(d.getDate() + daysAhead);
  d.setHours(pick(hours), 0, 0, 0);
  return d;
}

/** maxPlayers et durée selon le type de jeu */
export function gameConfig(type) {
  switch (type) {
    case "YUGIOH":    return { maxPlayers: 2, duration: pick([60, 90, 120]) };
    case "MAGIC":     return { maxPlayers: pick([2, 4]), duration: pick([60, 90, 120]) };
    case "POKEMON":   return { maxPlayers: pick([2, 4]), duration: pick([90, 120, 180]) };
    case "ONE_PIECE": return { maxPlayers: pick([2, 4]), duration: pick([90, 120]) };
    default:          return { maxPlayers: 2, duration: 90 };
  }
}
