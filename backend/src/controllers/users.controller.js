/**
 * Controller des utilisateurs
 * Gère le profil et les infos utilisateur
 */

import bcrypt from "bcryptjs";
import prisma from "../config/database.js";
import { cloudinary } from "../config/cloudinary.js";

const USER_SELECT = {
  id: true,
  email: true,
  username: true,
  bio: true,
  avatar: true,
  createdAt: true,
};

// GET /api/users/me
const getMe = async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
      select: USER_SELECT,
    });

    if (!user) {
      return res.status(404).json({ error: "Utilisateur non trouvé" });
    }

    res.json({ user });
  } catch (error) {
    next(error);
  }
};

// PUT /api/users/me
const updateMe = async (req, res, next) => {
  try {
    const { username, bio, avatar } = req.body;
    const data = {};

    if (username !== undefined) {
      const trimmed = username.trim();
      if (!trimmed) {
        return res.status(400).json({ error: "Pseudo invalide" });
      }
      const existing = await prisma.user.findFirst({
        where: { username: trimmed, NOT: { id: req.user.userId } },
      });
      if (existing) {
        return res.status(409).json({ error: "Ce pseudo est déjà pris" });
      }
      data.username = trimmed;
    }

    if (bio !== undefined) {
      data.bio = bio === "" ? null : bio;
    }

    if (avatar !== undefined) {
      data.avatar = avatar || null;
    }

    if (Object.keys(data).length === 0) {
      return res.status(400).json({ error: "Aucune donnée à mettre à jour" });
    }

    const user = await prisma.user.update({
      where: { id: req.user.userId },
      data,
      select: USER_SELECT,
    });

    res.json({ user });
  } catch (error) {
    next(error);
  }
};

// GET /api/users/:id
const getUserById = async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.params.id },
      select: USER_SELECT,
    });

    if (!user) {
      return res.status(404).json({ error: "Utilisateur non trouvé" });
    }

    res.json({ user });
  } catch (error) {
    next(error);
  }
};

// PUT /api/users/me/fcm-token
const updateFcmToken = async (req, res, next) => {
  try {
    const { token } = req.body;
    if (!token) {
      return res.status(400).json({ error: "Token FCM requis" });
    }

    await prisma.user.update({
      where: { id: req.user.userId },
      data: { fcmToken: token },
    });

    res.status(200).json({ message: "Token FCM mis à jour" });
  } catch (error) {
    next(error);
  }
};

// PUT /api/users/me/password
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        error: "Mot de passe actuel et nouveau mot de passe requis",
      });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({
        error: "Le nouveau mot de passe doit faire au moins 8 caractères",
      });
    }

    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
    });

    if (!user || !user.passwordHash) {
      return res.status(400).json({
        error: "Impossible de changer le mot de passe pour ce compte",
      });
    }

    const valid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!valid) {
      return res.status(401).json({ error: "Mot de passe actuel incorrect" });
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);
    await prisma.user.update({
      where: { id: req.user.userId },
      data: { passwordHash },
    });

    res.json({ message: "Mot de passe modifié" });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/users/me
const deleteMe = async (req, res, next) => {
  try {
    const userId = req.user.userId;

    const createdGames = await prisma.game.findMany({
      where: { creatorId: userId },
      select: { id: true },
    });
    const gameIds = createdGames.map((g) => g.id);

    await prisma.$transaction(async (tx) => {
      // Delete user's own notifications
      await tx.notification.deleteMany({ where: { userId } });

      if (gameIds.length > 0) {
        // Delete notifications referencing created games (other users)
        for (const gameId of gameIds) {
          await tx.$executeRaw`DELETE FROM notifications WHERE data->>'gameId' = ${gameId}`;
        }
        await tx.message.deleteMany({ where: { gameId: { in: gameIds } } });
        await tx.participation.deleteMany({
          where: { gameId: { in: gameIds } },
        });
        await tx.game.deleteMany({ where: { id: { in: gameIds } } });
      }

      // Delete user's messages and participations in other games
      await tx.message.deleteMany({ where: { senderId: userId } });
      await tx.participation.deleteMany({ where: { userId } });

      await tx.user.delete({ where: { id: userId } });
    });

    res.json({ message: "Compte supprimé" });
  } catch (error) {
    next(error);
  }
};

// PUT /api/users/me/avatar
const uploadAvatar = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "Aucun fichier fourni" });
    }

    const result = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        {
          folder: "duelfinder/avatars",
          transformation: [
            { width: 512, height: 512, crop: "fill", gravity: "face" },
          ],
          resource_type: "image",
        },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        },
      );
      stream.end(req.file.buffer);
    });

    const user = await prisma.user.update({
      where: { id: req.user.userId },
      data: { avatar: result.secure_url },
      select: USER_SELECT,
    });

    res.json({ user });
  } catch (error) {
    next(error);
  }
};

export default {
  getMe,
  updateMe,
  getUserById,
  updateFcmToken,
  changePassword,
  deleteMe,
  uploadAvatar,
};
