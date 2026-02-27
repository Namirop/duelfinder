import jwt from "jsonwebtoken";
import { jwt as jwtConfig } from "../config/index.js";

const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Token manquant" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, jwtConfig.jwt_secret);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: "Token invalide" });
  }
};

/**
 * Middleware optionnel - attache l'utilisateur si token présent, sinon continue sans bloquer
 */
const optionalAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    req.user = null;
    return next();
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, jwtConfig.jwt_secret);
    req.user = decoded;
  } catch (error) {
    req.user = null;
  }

  next();
};

export { authenticate, optionalAuth };
