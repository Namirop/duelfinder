/**
 * Script pour créer des parties de test autour d'une position
 *
 * Usage: node scripts/seed_test_games.js <latitude> <longitude>
 * Exemple: node scripts/seed_test_games.js 48.8566 2.3522
 */

import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

// Génère une position aléatoire dans un rayon donné (en km)
function randomPositionInRadius(lat, lng, radiusKm) {
  const radiusInDegrees = radiusKm / 111; // Approximation
  const u = Math.random();
  const v = Math.random();
  const w = radiusInDegrees * Math.sqrt(u);
  const t = 2 * Math.PI * v;
  const newLat = lat + w * Math.cos(t);
  const newLng = lng + (w * Math.sin(t)) / Math.cos((lat * Math.PI) / 180);
  return { latitude: newLat, longitude: newLng };
}

// Génère une date aléatoire dans les 7 prochains jours
function randomFutureDate() {
  const now = new Date();
  const daysAhead = Math.floor(Math.random() * 7) + 1;
  const hours = Math.floor(Math.random() * 10) + 10; // Entre 10h et 20h
  const date = new Date(now);
  date.setDate(date.getDate() + daysAhead);
  date.setHours(hours, 0, 0, 0);
  return date;
}

const GAME_TYPES = ["ONE_PIECE", "POKEMON", "YUGIOH"];
const ADDRESSES = [
  "Café des Joueurs, 12 rue du Commerce",
  "Game Store, 45 avenue de la République",
  "Espace Détente, 8 place du Marché",
  "La Taverne du Geek, 23 rue des Arts",
];

async function main() {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.log("Usage: node scripts/seed_test_games.js <latitude> <longitude>");
    console.log("Exemple: node scripts/seed_test_games.js 48.8566 2.3522");
    process.exit(1);
  }

  const centerLat = parseFloat(args[0]);
  const centerLng = parseFloat(args[1]);

  console.log(`\nCréation des parties de test autour de (${centerLat}, ${centerLng})\n`);

  // 1. Créer un utilisateur de test
  const existingUser = await prisma.user.findUnique({
    where: { email: "testgames@test.com" },
  });

  let testUser;
  if (existingUser) {
    testUser = existingUser;
    console.log("✓ Utilisateur de test existant trouvé");
  } else {
    const passwordHash = await bcrypt.hash("test123", 10);
    testUser = await prisma.user.create({
      data: {
        email: "testgames@test.com",
        username: "TestGamer",
        passwordHash,
        avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=TestGamer",
      },
    });
    console.log("✓ Utilisateur de test créé: TestGamer");
  }

  // 2. Supprimer les anciennes parties de test
  await prisma.game.deleteMany({
    where: { creatorId: testUser.id },
  });
  console.log("✓ Anciennes parties de test supprimées");

  // 3. Créer 3 parties dans un rayon de 20km
  const gamesNear = [];
  for (let i = 0; i < 3; i++) {
    const pos = randomPositionInRadius(centerLat, centerLng, 20);
    const game = await prisma.game.create({
      data: {
        gameType: GAME_TYPES[i % GAME_TYPES.length],
        description: `Partie de test ${i + 1} - Venez jouer !`,
        address: ADDRESSES[i % ADDRESSES.length],
        latitude: pos.latitude,
        longitude: pos.longitude,
        scheduledAt: randomFutureDate(),
        duration: [60, 90, 120][i % 3],
        maxPlayers: [2, 4, 4][i % 3],
        status: "OPEN",
        creatorId: testUser.id,
      },
    });
    gamesNear.push(game);
  }
  console.log("✓ 3 parties créées dans un rayon de 20km");

  // 4. Créer 1 partie dans un rayon de 50km (entre 40 et 50km)
  const posFar = randomPositionInRadius(centerLat, centerLng, 45);
  const gameFar = await prisma.game.create({
    data: {
      gameType: "POKEMON",
      description: "Partie éloignée - Tournoi amical",
      address: "Centre Commercial, Zone Lointaine",
      latitude: posFar.latitude,
      longitude: posFar.longitude,
      scheduledAt: randomFutureDate(),
      duration: 180,
      maxPlayers: 8,
      status: "OPEN",
      creatorId: testUser.id,
    },
  });
  console.log("✓ 1 partie créée à ~45km");

  // Résumé
  console.log("\n========== RÉSUMÉ ==========");
  console.log(`Centre: (${centerLat}, ${centerLng})`);
  console.log("\nParties proches (< 20km):");
  gamesNear.forEach((g, i) => {
    const dist = Math.sqrt(
      Math.pow((g.latitude - centerLat) * 111, 2) +
      Math.pow((g.longitude - centerLng) * 111 * Math.cos(centerLat * Math.PI / 180), 2)
    ).toFixed(1);
    console.log(`  ${i + 1}. ${g.gameType} - ${g.address} (~${dist}km)`);
  });

  const distFar = Math.sqrt(
    Math.pow((gameFar.latitude - centerLat) * 111, 2) +
    Math.pow((gameFar.longitude - centerLng) * 111 * Math.cos(centerLat * Math.PI / 180), 2)
  ).toFixed(1);
  console.log(`\nPartie éloignée (~${distFar}km):`);
  console.log(`  ${gameFar.gameType} - ${gameFar.address}`);

  console.log("\n✅ Seed terminé avec succès!\n");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
