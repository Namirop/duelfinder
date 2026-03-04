/**
 * Service des notifications
 * Gère l'envoi de notifications push via FCM et la persistance en base
 */

import prisma from "../config/database.js";
import { getFirebaseAdmin } from "../config/firebase.js";

/**
 * Envoie une notification push à un utilisateur et la sauvegarde en base
 * @param {string} userId - ID du destinataire
 * @param {{ type: string, title: string, body: string, data?: object }} payload
 */
const sendToUser = async (userId, { type, title, body, data = {} }) => {
  // Sauvegarder en base (historique notifications)
  await prisma.notification.create({
    data: { type, title, body, data, userId },
  });

  // Récupérer le token FCM de l'utilisateur
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { fcmToken: true },
  });

  if (!user?.fcmToken) return; // Pas de token → pas de push

  try {
    const admin = getFirebaseAdmin();
    // Les valeurs dans data doivent être des strings pour FCM
    const stringData = { type, ...Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    )};

    await admin.messaging().send({
      token: user.fcmToken,
      notification: { title, body },
      data: stringData,
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    });
  } catch (err) {
    console.error(`[FCM] Échec envoi à user ${userId}:`, err.message);
    // Token invalide → on le supprime pour éviter de réessayer
    if (err.code === "messaging/registration-token-not-registered") {
      await prisma.user.update({
        where: { id: userId },
        data: { fcmToken: null },
      });
    }
  }
};

/**
 * Envoie une notification à plusieurs utilisateurs
 * @param {string[]} userIds
 * @param {{ type: string, title: string, body: string, data?: object }} payload
 */
const sendToUsers = async (userIds, payload) => {
  await Promise.all(userIds.map((userId) => sendToUser(userId, payload)));
};

export default { sendToUser, sendToUsers };
