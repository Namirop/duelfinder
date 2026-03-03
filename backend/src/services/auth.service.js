/**
 * Service d'authentification
 * Contient la logique métier liée à l'authentification
 */

import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { jwt as jwtConfig } from "../config/index.js";
import prisma from "../config/database.js";

const SALT_ROUNDS = 10;

const hashPassword = async (password) => {
  return bcrypt.hash(password, SALT_ROUNDS);
};

const comparePassword = async (password, hash) => {
  return bcrypt.compare(password, hash);
};

const generateTokens = (userId) => {
  const accessToken = jwt.sign({ userId }, jwtConfig.jwt_secret, {
    expiresIn: jwtConfig.access_token_expiry,
  });
  const refreshToken = jwt.sign({ userId }, jwtConfig.jwt_refresh_secret, {
    expiresIn: jwtConfig.refresh_token_expiry,
  });
  return { accessToken, refreshToken };
};

const verifyToken = (token) => {
  return jwt.verify(token, jwtConfig.jwt_secret);
};

const verifyRefreshToken = (token) => {
  return jwt.verify(token, jwtConfig.jwt_refresh_secret);
};

const findUserByEmail = async (email) => {
  return prisma.user.findUnique({ where: { email } });
};

const findUserById = async (id) => {
  return prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      email: true,
      username: true,
      bio: true,
      avatar: true,
      createdAt: true,
    },
  });
};

const generateAccessToken = (userId) => {
  return jwt.sign({ userId }, jwtConfig.jwt_secret, {
    expiresIn: jwtConfig.access_token_expiry,
  });
};

const createUser = async ({ email, password, username }) => {
  const passwordHash = await hashPassword(password);
  const avatar = `https://api.dicebear.com/7.x/avataaars/png?seed=${encodeURIComponent(username)}`;

  return prisma.user.create({
    data: {
      email,
      passwordHash,
      username,
      avatar,
    },
    select: {
      id: true,
      email: true,
      username: true,
      bio: true,
      avatar: true,
      createdAt: true,
    },
  });
};

/**
 * Valide un token Facebook et récupère les infos utilisateur
 * @param {string} accessToken - Token d'accès Facebook
 * @returns {Promise<{id: string, name: string, email?: string, picture?: object}>}
 */
const validateFacebookToken = async (accessToken) => {
  const url = `https://graph.facebook.com/me?fields=id,name,email,picture&access_token=${accessToken}`;
  const response = await fetch(url);

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(error.error?.message || "Token Facebook invalide");
  }

  return response.json();
};

/**
 * Valide un token Instagram et récupère les infos utilisateur
 * @param {string} accessToken - Token d'accès Instagram
 * @returns {Promise<{id: string, username: string}>}
 */
const validateInstagramToken = async (accessToken) => {
  const url = `https://graph.instagram.com/me?fields=id,username&access_token=${accessToken}`;
  const response = await fetch(url);

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(error.error?.message || "Token Instagram invalide");
  }

  return response.json();
};

/**
 * Trouve ou crée un utilisateur OAuth
 * @param {object} params
 * @param {'facebook'|'instagram'} params.provider - Le provider OAuth
 * @param {string} params.providerId - L'ID unique du provider
 * @param {string} [params.email] - Email (optionnel, non fourni par Instagram)
 * @param {string} [params.username] - Nom d'utilisateur
 * @param {string} [params.avatar] - URL de l'avatar
 * @returns {Promise<object>} L'utilisateur trouvé ou créé
 */
const findOrCreateOAuthUser = async ({
  provider,
  providerId,
  email,
  username,
  avatar,
}) => {
  const field = provider === "facebook" ? "facebookId" : "instagramId";

  // 1. Chercher par provider ID
  let user = await prisma.user.findUnique({ where: { [field]: providerId } });
  if (user) {
    return {
      id: user.id,
      email: user.email,
      username: user.username,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
    };
  }

  // 2. Chercher par email (si fourni) pour lier les comptes
  if (email) {
    user = await prisma.user.findUnique({ where: { email } });
    if (user) {
      // Lier le provider au compte existant
      const updatedUser = await prisma.user.update({
        where: { id: user.id },
        data: { [field]: providerId },
        select: {
          id: true,
          email: true,
          username: true,
          avatarUrl: true,
          createdAt: true,
        },
      });
      return updatedUser;
    }
  }

  // 3. Créer un nouveau compte
  return prisma.user.create({
    data: {
      email,
      username,
      avatarUrl: avatar,
      [field]: providerId,
    },
    select: {
      id: true,
      email: true,
      username: true,
      avatarUrl: true,
      createdAt: true,
    },
  });
};

export default {
  hashPassword,
  comparePassword,
  generateTokens,
  generateAccessToken,
  verifyToken,
  verifyRefreshToken,
  findUserByEmail,
  findUserById,
  createUser,
  validateFacebookToken,
  validateInstagramToken,
  findOrCreateOAuthUser,
};
