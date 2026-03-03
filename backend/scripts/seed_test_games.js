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
function randomPositionInRadius(lat, lng, minRadiusKm, maxRadiusKm) {
  const minRadius = minRadiusKm / 111;
  const maxRadius = maxRadiusKm / 111;
  const u = Math.random();
  const v = Math.random();
  // Rayon entre min et max
  const w = minRadius + (maxRadius - minRadius) * Math.sqrt(u);
  const t = 2 * Math.PI * v;
  const newLat = lat + w * Math.cos(t);
  const newLng = lng + (w * Math.sin(t)) / Math.cos((lat * Math.PI) / 180);
  return { latitude: newLat, longitude: newLng };
}

// Génère une date à X jours dans le futur
function futureDate(daysAhead, hour = 14) {
  const date = new Date();
  date.setDate(date.getDate() + daysAhead);
  date.setHours(hour, 0, 0, 0);
  return date;
}

const GAME_TYPES = ["ONE_PIECE", "POKEMON", "YUGIOH", "NARUTO"];

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
    where: { email: "testgamer@duelfinder.com" },
  });

  let testUser;
  if (existingUser) {
    testUser = existingUser;
    console.log("✓ Utilisateur de test existant trouvé");
  } else {
    const passwordHash = await bcrypt.hash("test123", 10);
    testUser = await prisma.user.create({
      data: {
        email: "testgamer@duelfinder.com",
        username: "TestGamer",
        bio: "Joueur passionné de TCG depuis 10 ans !",
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

  // 3. Créer 3 parties dans un rayon de 30km
  const gamesNear = [];

  // Partie 1: Aujourd'hui (dans quelques heures)
  const pos1 = randomPositionInRadius(centerLat, centerLng, 5, 15);
  const game1 = await prisma.game.create({
    data: {
      gameType: "POKEMON",
      description: "Partie débutants bienvenue !",
      address: "Game Store, 45 avenue de la République",
      latitude: pos1.latitude,
      longitude: pos1.longitude,
      scheduledAt: futureDate(0, 18), // Aujourd'hui à 18h
      duration: 60,
      maxPlayers: 4,
      status: "OPEN",
      creatorId: testUser.id,
    },
  });
  gamesNear.push({ ...game1, label: "Aujourd'hui" });
  console.log("✓ Partie 1 créée (aujourd'hui)");

  // Partie 2: Demain
  const pos2 = randomPositionInRadius(centerLat, centerLng, 10, 25);
  const game2 = await prisma.game.create({
    data: {
      gameType: "ONE_PIECE",
      description: "Tournoi amical One Piece",
      address: "Café des Joueurs, 12 rue du Commerce",
      latitude: pos2.latitude,
      longitude: pos2.longitude,
      scheduledAt: futureDate(1, 15), // Demain à 15h
      duration: 90,
      maxPlayers: 4,
      status: "OPEN",
      creatorId: testUser.id,
    },
  });
  gamesNear.push({ ...game2, label: "Demain" });
  console.log("✓ Partie 2 créée (demain)");

  // Partie 3: Dans 4 jours
  const pos3 = randomPositionInRadius(centerLat, centerLng, 15, 28);
  const game3 = await prisma.game.create({
    data: {
      gameType: "YUGIOH",
      description: "Session Yu-Gi-Oh! du weekend",
      address: "Espace Détente, 8 place du Marché",
      latitude: pos3.latitude,
      longitude: pos3.longitude,
      scheduledAt: futureDate(4, 14), // Dans 4 jours à 14h
      duration: 120,
      maxPlayers: 2,
      status: "OPEN",
      creatorId: testUser.id,
    },
  });
  gamesNear.push({ ...game3, label: "Dans 4 jours" });
  console.log("✓ Partie 3 créée (dans 4 jours)");

  // 4. Créer 1 partie à ~60km
  const posFar = randomPositionInRadius(centerLat, centerLng, 55, 65);
  const gameFar = await prisma.game.create({
    data: {
      gameType: "NARUTO",
      description: "Grand tournoi régional Naruto",
      address: "Centre Commercial, Zone Lointaine",
      latitude: posFar.latitude,
      longitude: posFar.longitude,
      scheduledAt: futureDate(2, 10), // Dans 2 jours à 10h
      duration: 180,
      maxPlayers: 8,
      status: "OPEN",
      creatorId: testUser.id,
    },
  });
  console.log("✓ Partie éloignée créée (~60km)");

  // Fonction pour calculer la distance
  const calcDistance = (lat, lng) => {
    return Math.sqrt(
      Math.pow((lat - centerLat) * 111, 2) +
      Math.pow((lng - centerLng) * 111 * Math.cos(centerLat * Math.PI / 180), 2)
    ).toFixed(1);
  };

  // Résumé
  console.log("\n========== RÉSUMÉ ==========");
  console.log(`Centre: (${centerLat}, ${centerLng})`);
  console.log(`\nUtilisateur: ${testUser.username} (${testUser.email})`);
  console.log("\nParties proches (< 30km):");
  gamesNear.forEach((g, i) => {
    const dist = calcDistance(g.latitude, g.longitude);
    const date = new Date(g.scheduledAt).toLocaleDateString('fr-FR', {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      hour: '2-digit',
      minute: '2-digit'
    });
    console.log(`  ${i + 1}. [${g.label}] ${g.gameType} - ${g.address}`);
    console.log(`     📍 ~${dist}km | 📅 ${date}`);
  });

  const distFar = calcDistance(gameFar.latitude, gameFar.longitude);
  const dateFar = new Date(gameFar.scheduledAt).toLocaleDateString('fr-FR', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    hour: '2-digit',
    minute: '2-digit'
  });
  console.log(`\nPartie éloignée (~60km):`);
  console.log(`  ${gameFar.gameType} - ${gameFar.address}`);
  console.log(`  📍 ~${distFar}km | 📅 ${dateFar}`);

  console.log("\n✅ Seed terminé avec succès!\n");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
