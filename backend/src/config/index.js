export const jwt = {
  jwt_secret: process.env.JWT_SECRET,
  jwt_refresh_secret: process.env.JWT_REFRESH_SECRET,
  access_token_expiry: process.env.ACCESS_TOKEN_EXPIRY || "15m",
  refresh_token_expiry: process.env.REFRESH_TOKEN_EXPIRY || "7d",
};
export const oauth = {
  facebook: {
    appId: process.env.FACEBOOK_APP_ID,
    appSecret: process.env.FACEBOOK_APP_SECRET,
  },
  instagram: {
    clientId: process.env.INSTAGRAM_CLIENT_ID,
    clientSecret: process.env.INSTAGRAM_CLIENT_SECRET,
  },
};
