import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";

import routes from "./routes/index.js";
import { errorHandler, notFound } from "./middlewares/index.js";

const app = express();

// ===========================================
// Middlewares de sécurité
// ===========================================
app.use(helmet());
app.use(cors());

// ===========================================
// Middlewares de parsing
// ===========================================
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (process.env.NODE_ENV !== "production") {
  app.use(morgan("dev"));
}

app.use("/api", routes);

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", timestamp: new Date().toISOString() });
});

// ===========================================
// Gestion des erreurs
// ===========================================
app.use(notFound);
app.use(errorHandler);

export const listen = app.listen.bind(app);
export default app;
