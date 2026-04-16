import { authenticate, optionalAuth } from "./auth.js";
import { errorHandler, notFound } from "./errorHandler.js";
import {
  globalLimiter,
  authLimiter,
  createGameLimiter,
  participationLimiter,
} from "./rateLimit.js";
import { uploadAvatar } from "./upload.js";

export {
  authenticate,
  optionalAuth,
  errorHandler,
  notFound,
  globalLimiter,
  authLimiter,
  createGameLimiter,
  participationLimiter,
  uploadAvatar,
};
