/**
 * seed_launch.js — Seed content NPC pour le lancement de DuelFinder
 * Phase 1 : peuplement initial de la map (one-shot)
 *
 * - Crée 20 comptes NPC (emails @npc.duelfinder.com)
 * - Crée des parties sur 30 jours selon la densité de chaque ville (cf. npc_config.js)
 * - ~30% des parties sont FULL (social proof), ~70% sont OPEN (visibles sur map)
 * - Ajoute quelques messages dans les chats des parties FULL
 *
 * Run :        node scripts/seed_launch.js
 * Re-seed :    node scripts/seed_launch.js --force
 * Idempotent : s'arrête si des NPCs existent déjà (sauf avec --force)
 */

import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";
import {
  CITIES,
  NPC_EMAIL_SUFFIX,
  NPC_PROFILES,
  GAME_DESCRIPTIONS,
  CHAT_MESSAGES,
} from "./npc_config.js";
import { pick, jitter, futureDate as scheduledAt, gameConfig, GAME_TYPES } from "./utils.js";

const prisma = new PrismaClient();

// ─── CLEANUP INTERNE (utilisé avec --force) ───────────────────────────────────

async function cleanupExistingNPCs() {
  const npcUsers = await prisma.user.findMany({
    where: { email: { endsWith: NPC_EMAIL_SUFFIX } },
    select: { id: true },
  });
  if (npcUsers.length === 0) return;

  const npcUserIds = npcUsers.map((u) => u.id);
  const npcGames = await prisma.game.findMany({
    where: { creatorId: { in: npcUserIds } },
    select: { id: true },
  });
  const npcGameIds = npcGames.map((g) => g.id);

  await prisma.message.deleteMany({ where: { gameId: { in: npcGameIds } } });
  await prisma.participation.deleteMany({
    where: { OR: [{ gameId: { in: npcGameIds } }, { userId: { in: npcUserIds } }] },
  });
  await prisma.notification.deleteMany({ where: { userId: { in: npcUserIds } } });
  await prisma.game.deleteMany({ where: { id: { in: npcGameIds } } });
  await prisma.user.deleteMany({ where: { id: { in: npcUserIds } } });
  console.log(`✓  Données NPC existantes supprimées (${npcUsers.length} users, ${npcGames.length} parties)`);
}

// ─── MAIN ──────────────────────────────────────────────────────────────────────

async function main() {
  const forceFlag = process.argv.includes("--force");

  // Vérification idempotence
  const existingCount = await prisma.user.count({
    where: { email: { endsWith: NPC_EMAIL_SUFFIX } },
  });

  if (existingCount > 0 && !forceFlag) {
    console.log(`\n⚠️  ${existingCount} utilisateurs NPC déjà présents.`);
    console.log("    Utilisez --force pour réinitialiser le seed content.\n");
    return;
  }

  if (forceFlag && existingCount > 0) {
    console.log("\n🔄  --force détecté, suppression des données NPC existantes...");
    await cleanupExistingNPCs();
  }

  console.log("\n🚀  SEED LAUNCH NPC — DuelFinder\n");

  // ── 1. CRÉATION DES UTILISATEURS NPC ────────────────────────────────────────
  console.log("👥  Création des utilisateurs NPC...");

  // Mot de passe inutilisable volontairement (les NPCs ne se connectent jamais)
  const npcPasswordHash = await bcrypt.hash("__npc_account_not_loginable__", 10);

  const npcUsers = await Promise.all(
    NPC_PROFILES.map((profile) =>
      prisma.user.create({
        data: {
          email: `npc.${profile.username.toLowerCase()}${NPC_EMAIL_SUFFIX}`,
          passwordHash: npcPasswordHash,
          username: profile.username,
          bio: profile.bio,
          avatar: `https://api.dicebear.com/7.x/avataaars/png?seed=${encodeURIComponent(profile.username)}`,
          badgeLevel: profile.badgeLevel,
          totalGamesPlayed: profile.totalGamesPlayed,
        },
      })
    )
  );

  console.log(`✓  ${npcUsers.length} utilisateurs NPC créés`);

  // ── 2. CRÉATION DES PARTIES ──────────────────────────────────────────────────
  console.log("\n🎮  Création des parties...");

  let totalGames = 0;
  let totalFull = 0;
  const createdFullGames = []; // pour ajouter des messages ensuite

  for (const city of CITIES) {
    for (const day of city.slots) {
      const creator = pick(npcUsers);
      const venue = pick(city.venues);
      const gameType = pick(GAME_TYPES);
      const description = pick(GAME_DESCRIPTIONS[gameType]);
      const { maxPlayers, duration } = gameConfig(gameType);
      const coords = jitter(city.lat, city.lng);

      // 30% des parties sont FULL (social proof)
      const isFull = Math.random() < 0.3;

      const game = await prisma.game.create({
        data: {
          gameType,
          description,
          address: venue.address,
          latitude: coords.lat,
          longitude: coords.lng,
          scheduledAt: scheduledAt(day),
          duration,
          maxPlayers,
          status: isFull ? "FULL" : "OPEN",
          wasFilledOnce: isFull,
          creatorId: creator.id,
        },
      });

      if (isFull) {
        // Remplit la partie avec des participants NPC
        const slots = maxPlayers - 1;
        const participants = npcUsers
          .filter((u) => u.id !== creator.id)
          .sort(() => Math.random() - 0.5)
          .slice(0, slots);

        await Promise.all(
          participants.map((p) =>
            prisma.participation.create({
              data: {
                userId: p.id,
                gameId: game.id,
                status: "ACCEPTED",
                acceptedAt: new Date(Date.now() - Math.random() * 48 * 3600 * 1000),
              },
            })
          )
        );

        createdFullGames.push({ game, creator, participants });
        totalFull++;
      }

      totalGames++;
    }

    console.log(`  ✓  ${city.name} : ${city.slots.length} parties créées`);
  }

  console.log(`\n✓  ${totalGames} parties créées au total`);
  console.log(`   └─ ${totalFull} FULL (social proof)`);
  console.log(`   └─ ${totalGames - totalFull} OPEN (visibles sur la map)`);

  // ── 3. MESSAGES DANS QUELQUES CHATS ─────────────────────────────────────────
  console.log("\n💬  Ajout de messages dans quelques chats...");

  // On prend max 10 parties FULL au hasard pour y mettre des messages
  const gamesToChat = createdFullGames
    .sort(() => Math.random() - 0.5)
    .slice(0, 10);

  for (const { game, creator, participants } of gamesToChat) {
    const speakers = [{ id: creator.id }, ...participants.map((p) => ({ id: p.id }))];
    const messageCount = 3 + Math.floor(Math.random() * 4); // 3 à 6 messages
    let timeOffset = (2 + Math.random() * 6) * 3600 * 1000; // il y a 2-8h

    for (let i = 0; i < Math.min(messageCount, CHAT_MESSAGES.length); i++) {
      await prisma.message.create({
        data: {
          gameId: game.id,
          senderId: speakers[i % speakers.length].id,
          content: CHAT_MESSAGES[i],
          createdAt: new Date(Date.now() - timeOffset),
        },
      });
      timeOffset -= Math.random() * 20 * 60 * 1000; // espace de 0-20min entre messages
    }
  }

  console.log(`✓  Messages ajoutés dans ${gamesToChat.length} parties`);

  // ── RÉSUMÉ ───────────────────────────────────────────────────────────────────
  console.log("\n══════════════════════════════════════════════════════════════");
  console.log("✅  SEED LAUNCH TERMINÉ\n");
  console.log(`  👥  ${npcUsers.length} utilisateurs NPC`);
  console.log(`  🎮  ${totalGames} parties sur ${CITIES.length} villes (30 jours)`);
  console.log(`  📍  Villes : ${CITIES.map((c) => c.name).join(", ")}`);
  console.log(`\n  Prochaines étapes :`);
  console.log(`  → Configurer le cron quotidien : node scripts/cron_daily.js`);
  console.log(`  → Nettoyer quand l'app est réelle : node scripts/cleanup_ghost.js --force`);
  console.log("══════════════════════════════════════════════════════════════\n");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
