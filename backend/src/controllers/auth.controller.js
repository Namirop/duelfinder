import authService from "../services/auth.service.js";

// POST /api/auth/register
const register = async (req, res, next) => {
  try {
    const { email, password, username } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email et mot de passe requis" });
    }

    if (!username) {
      return res.status(400).json({ error: "Pseudo requis" });
    }

    const existingUser = await authService.findUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({ error: "Cet utilisateur existe déjà" });
    }

    const user = await authService.createUser({ email, password, username });
    const tokens = authService.generateTokens(user.id);

    res.status(201).json({ user, ...tokens });
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/login
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email et mot de passe requis" });
    }

    const user = await authService.findUserByEmail(email);
    if (!user) {
      return res.status(401).json({ error: "Identifiants incorrects" });
    }

    const validPassword = await authService.comparePassword(
      password,
      user.passwordHash,
    );
    if (!validPassword) {
      return res.status(401).json({ error: "Identifiants incorrects" });
    }

    const tokens = authService.generateTokens(user.id);

    res.json({
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        avatar: user.avatar,
        createdAt: user.createdAt,
      },
      ...tokens,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/auth/me - Récupérer l'utilisateur connecté
const getMe = async (req, res, next) => {
  try {
    const user = await authService.findUserById(req.user.userId);

    if (!user) {
      return res.status(404).json({ error: "Utilisateur non trouvé" });
    }

    res.json({ user });
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/refresh
const refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res
        .status(400)
        .json({ error: "Token de rafraîchissement requis" });
    }

    const decoded = authService.verifyRefreshToken(refreshToken);

    const user = await authService.findUserById(decoded.userId);
    if (!user) {
      return res.status(401).json({ error: "Utilisateur non trouvé" });
    }

    const accessToken = authService.generateAccessToken(user.id);

    res.json({ accessToken });
  } catch (error) {
    if (
      error.name === "JsonWebTokenError" ||
      error.name === "TokenExpiredError"
    ) {
      return res.status(401).json({ error: "Token invalide ou expiré" });
    }
    next(error);
  }
};

// POST /api/auth/facebook
const facebookAuth = async (req, res, next) => {
  try {
    const { accessToken } = req.body;

    if (!accessToken) {
      return res.status(400).json({ error: "Token Facebook requis" });
    }

    // Valider le token avec l'API Facebook
    const fbUser = await authService.validateFacebookToken(accessToken);

    // Trouver ou créer l'utilisateur
    const user = await authService.findOrCreateOAuthUser({
      provider: "facebook",
      providerId: fbUser.id,
      email: fbUser.email,
      username: fbUser.name,
      avatar: fbUser.picture?.data?.url,
    });

    // Générer les tokens JWT
    const tokens = authService.generateTokens(user.id);

    res.json({ user, ...tokens });
  } catch (error) {
    if (error.message.includes("Token Facebook invalide")) {
      return res.status(401).json({ error: error.message });
    }
    next(error);
  }
};

// POST /api/auth/instagram
const instagramAuth = async (req, res, next) => {
  try {
    const { accessToken } = req.body;

    if (!accessToken) {
      return res.status(400).json({ error: "Token Instagram requis" });
    }

    // Valider le token avec l'API Instagram
    const igUser = await authService.validateInstagramToken(accessToken);

    // Trouver ou créer l'utilisateur (Instagram ne fournit pas l'email)
    const user = await authService.findOrCreateOAuthUser({
      provider: "instagram",
      providerId: igUser.id,
      username: igUser.username,
    });

    // Générer les tokens JWT
    const tokens = authService.generateTokens(user.id);

    res.json({ user, ...tokens });
  } catch (error) {
    if (error.message.includes("Token Instagram invalide")) {
      return res.status(401).json({ error: error.message });
    }
    next(error);
  }
};

export default {
  register,
  login,
  getMe,
  refreshToken,
  facebookAuth,
  instagramAuth,
};
