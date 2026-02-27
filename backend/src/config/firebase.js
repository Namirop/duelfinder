import admin from "firebase-admin";

/**
 * Initialise Firebase Admin SDK pour les notifications FCM
 */
const initializeFirebase = () => {
  try {
    if (!process.env.FIREBASE_PROJECT_ID) {
      console.warn(
        "⚠️  Firebase non configuré - Variables d'environnement manquantes",
      );
      return null;
    }

    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      }),
    });

    console.log("✅ Firebase Admin SDK initialisé");
    return admin;
  } catch (error) {
    console.error("❌ Erreur initialisation Firebase:", error.message);
    return null;
  }
};

/**
 * Retourne l'instance Firebase Admin
 */
const getFirebaseAdmin = () => {
  return admin;
};

export { initializeFirebase, getFirebaseAdmin };
