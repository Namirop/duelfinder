/**
 * Middleware de rate limiting
 * Protège l'API contre les abus et le spam
 */

// Store en mémoire pour le rate limiting (simple, suffisant pour la V1)
const requestCounts = new Map();

// Nettoyer le store périodiquement (toutes les minutes)
setInterval(() => {
  const now = Date.now();
  for (const [key, data] of requestCounts.entries()) {
    if (now > data.resetTime) {
      requestCounts.delete(key);
    }
  }
}, 60 * 1000);

/**
 * Crée un middleware de rate limiting
 * @param {Object} options - Configuration
 * @param {number} options.windowMs - Fenêtre de temps en ms (défaut: 1 minute)
 * @param {number} options.max - Nombre max de requêtes par fenêtre (défaut: 100)
 * @param {string} options.message - Message d'erreur personnalisé
 * @returns {Function} Middleware Express
 */
const createRateLimiter = ({
  windowMs = 60 * 1000,
  max = 100,
  message = "Trop de requêtes, veuillez réessayer plus tard",
} = {}) => {
  return (req, res, next) => {
    // Clé unique par IP + route (pour des limites différentes par endpoint)
    const ip = req.ip || req.connection.remoteAddress || "unknown";
    const key = `${ip}:${req.baseUrl || "global"}`;

    const now = Date.now();
    let data = requestCounts.get(key);

    if (!data || now > data.resetTime) {
      // Nouvelle fenêtre
      data = {
        count: 1,
        resetTime: now + windowMs,
      };
      requestCounts.set(key, data);
    } else {
      data.count++;
    }

    // Headers informatifs
    res.setHeader("X-RateLimit-Limit", max);
    res.setHeader("X-RateLimit-Remaining", Math.max(0, max - data.count));
    res.setHeader("X-RateLimit-Reset", Math.ceil(data.resetTime / 1000));

    if (data.count > max) {
      return res.status(429).json({
        error: message,
        retryAfter: Math.ceil((data.resetTime - now) / 1000),
      });
    }

    next();
  };
};

// Rate limiter global (100 requêtes par minute)
export const globalLimiter = createRateLimiter({
  windowMs: 60 * 1000,
  max: 100,
  message: "Trop de requêtes, veuillez réessayer dans une minute",
});

// Rate limiter strict pour l'authentification (10 tentatives par 15 min)
export const authLimiter = createRateLimiter({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message:
    "Trop de tentatives de connexion, veuillez réessayer dans 15 minutes",
});

// Rate limiter pour la création de parties (5 par heure)
export const createGameLimiter = createRateLimiter({
  windowMs: 60 * 60 * 1000,
  max: 5,
  message: "Vous avez créé trop de parties, veuillez réessayer plus tard",
});

// Rate limiter pour les demandes de participation (20 par heure)
export const participationLimiter = createRateLimiter({
  windowMs: 60 * 60 * 1000,
  max: 20,
  message: "Trop de demandes de participation, veuillez réessayer plus tard",
});

export default {
  createRateLimiter,
  globalLimiter,
  authLimiter,
  createGameLimiter,
  participationLimiter,
};
