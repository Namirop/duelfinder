/**
 * Controller des utilisateurs
 * Gère le profil et les infos utilisateur
 */

import prisma from "../config/database.js";

// GET /api/users/me
const getMe = async (req, res, next) => {
  // TODO: Récupérer l'utilisateur connecté depuis req.user
  // TODO: Retourner les infos du profil (sans le mot de passe)

  res.status(501).json({ message: 'TODO: Implémenter getMe' });
};

// PUT /api/users/me
const updateMe = async (req, res, next) => {
  // TODO: Valider les données d'entrée (username, avatar, bio)
  // TODO: Mettre à jour l'utilisateur en base
  // TODO: Retourner les nouvelles infos

  res.status(501).json({ message: 'TODO: Implémenter updateMe' });
};

// GET /api/users/:id
const getUserById = async (req, res, next) => {
  // TODO: Valider l'ID utilisateur
  // TODO: Récupérer l'utilisateur en base
  // TODO: Retourner les infos publiques du profil

  res.status(501).json({ message: 'TODO: Implémenter getUserById' });
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

// DELETE /api/users/me
const deleteMe = async (req, res, next) => {
  // TODO: Supprimer l'utilisateur et ses données associées
  // TODO: Gérer les cascades (participations, messages, etc.)
  // TODO: Retourner confirmation

  res.status(501).json({ message: 'TODO: Implémenter deleteMe' });
};

export default {
  getMe,
  updateMe,
  getUserById,
  updateFcmToken,
  deleteMe,
};
