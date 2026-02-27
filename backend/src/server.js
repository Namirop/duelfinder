import "dotenv/config";

import { listen } from "./app.js";
import { initializeFirebase } from "./config/firebase.js";

const PORT = process.env.PORT || 3000;

initializeFirebase();

listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || "development"}`);
});
