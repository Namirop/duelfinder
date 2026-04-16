import { v2 as cloudinary } from "cloudinary";

const initializeCloudinary = () => {
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
  const apiKey = process.env.CLOUDINARY_API_KEY;
  const apiSecret = process.env.CLOUDINARY_API_SECRET;

  if (!cloudName || !apiKey || !apiSecret) {
    console.warn(
      "⚠️  Cloudinary non configuré — variables d'environnement manquantes",
    );
    return null;
  }

  cloudinary.config({
    cloud_name: cloudName,
    api_key: apiKey,
    api_secret: apiSecret,
  });

  console.log("✅ Cloudinary configuré");
  return cloudinary;
};

export { initializeCloudinary, cloudinary };
