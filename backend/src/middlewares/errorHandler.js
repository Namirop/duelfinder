/**
 * Middleware de gestion des erreurs 404
 */
export const notFound = (req, res, next) => {
  res.status(404).json({ error: "Route non trouvée" });
};

/**
 * Middleware de gestion globale des erreurs
 * Doit être le dernier middleware enregistré
 */
export const errorHandler = (err, req, res, next) => {
  console.error(err.stack);

  const statusCode = err.status || err.statusCode || 500;

  res.status(statusCode).json({
    error:
      process.env.NODE_ENV === "production"
        ? "Erreur serveur interne"
        : err.message,
  });
};
