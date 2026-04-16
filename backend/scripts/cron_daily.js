/**
 * cron_daily.js — Maintenance quotidienne du seed content NPC
 * Phase 2 : à lancer chaque soir (recommandé : 23h00)
 *
 * Ce script fait 3 choses :
 *   1. PRUNE      — supprime les parties NPC dont la date est passée
 *   2. AUTO-REJECT — rejette les demandes PENDING de vrais users sur parties NPC
 *                    (après AUTO_REJECT_AFTER_HOURS heures sans réponse)
 *   3. REPLENISH  — crée de nouvelles parties si une ville est sous le seuil minimum
 *
 * Run manuel :  node scripts/cron_daily.js
 *
 * Cron système (Linux/Mac) :
 *   0 23 * * * cd /app/backend && node scripts/cron_daily.js >> /var/log/npc-cron.log 2>&1
 *
 * Railway / Heroku Scheduler :
 *   Commande : npm run npc:cron  |  Fréquence : Daily
 */

import { PrismaClient } from "@prisma/client";
import {
  CITIES,
  NPC_EMAIL_SUFFIX,
  GAME_DESCRIPTIONS,
  CRON_CONFIG,
} from "./npc_config.js";
import { pick, jitter, futureDate, gameConfig, GAME_TYPES } from "./utils.js";

const prisma = new PrismaClient();

const {
  MIN_OPEN_GAMES_PER_CITY,
  HORIZON_DAYS,
  NEW_GAMES_PER_REPLENISH,
  AUTO_REJECT_AFTER_HOURS,
  CITY_RADIUS_DEG,
} = CRON_CONFIG;

// ─── DB READINESS CHECK ────────────────────────────────────────────────────────

async function waitForDatabase(maxRetries = 5, delayMs = 5000) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await prisma.$queryRaw`SELECT 1`;
      console.log(`✅  Database ready (attempt ${attempt}/${maxRetries})`);
      return;
    } catch (err) {
      console.log(
        `⏳  Database not ready (attempt ${attempt}/${maxRetries}): ${err.message}`,
      );
      if (attempt === maxRetries) {
        throw new Error(
          `Database not available after ${maxRetries} attempts — aborting cron.`,
        );
      }
      await new Promise((r) => setTimeout(r, delayMs * attempt));
    }
  }
}

// ─── MAIN ──────────────────────────────────────────────────────────────────────

async function main() {
  await waitForDatabase();
  const now = new Date();
  const horizonEnd = new Date(now.getTime() + HORIZON_DAYS * 24 * 3600 * 1000);

  console.log(`\n⏰  Cron NPC — ${now.toLocaleString("fr-FR")}\n`);

  // Récupère tous les users NPC
  const npcUsers = await prisma.user.findMany({
    where: { email: { endsWith: NPC_EMAIL_SUFFIX } },
    select: { id: true },
  });

  if (npcUsers.length === 0) {
    console.log(
      "⚠️  Aucun utilisateur NPC trouvé. Lancez d'abord : node scripts/seed_launch.js",
    );
    return;
  }

  const npcUserIds = npcUsers.map((u) => u.id);

  // ── 1. PRUNE : supprime les parties NPC terminées ────────────────────────────
  console.log("🗑️  Nettoyage des parties expirées...");

  const expiredGames = await prisma.game.findMany({
    where: {
      creatorId: { in: npcUserIds },
      scheduledAt: { lt: now },
    },
    select: { id: true },
  });

  if (expiredGames.length > 0) {
    const expiredIds = expiredGames.map((g) => g.id);
    await prisma.message.deleteMany({ where: { gameId: { in: expiredIds } } });
    await prisma.participation.deleteMany({
      where: { gameId: { in: expiredIds } },
    });
    await prisma.game.deleteMany({ where: { id: { in: expiredIds } } });
    console.log(`  ✓  ${expiredGames.length} parties NPC supprimées`);
  } else {
    console.log("  ✓  Aucune partie expirée");
  }

  // ── 2. AUTO-REJECT : rejette les demandes de vrais users restées sans réponse ─
  console.log("\n❌  Traitement des demandes sans réponse...");

  const rejectCutoff = new Date(
    now.getTime() - AUTO_REJECT_AFTER_HOURS * 3600 * 1000,
  );

  const pendingToReject = await prisma.participation.findMany({
    where: {
      status: "PENDING",
      createdAt: { lt: rejectCutoff },
      game: { creatorId: { in: npcUserIds } },
      // Seulement les vrais utilisateurs (pas d'autres NPCs)
      user: { email: { not: { endsWith: NPC_EMAIL_SUFFIX } } },
    },
    select: { id: true },
  });

  if (pendingToReject.length > 0) {
    await prisma.participation.updateMany({
      where: { id: { in: pendingToReject.map((p) => p.id) } },
      data: { status: "REJECTED" },
    });
    console.log(
      `  ✓  ${pendingToReject.length} demande(s) rejetée(s) (>${AUTO_REJECT_AFTER_HOURS}h sans réponse)`,
    );
  } else {
    console.log("  ✓  Aucune demande en attente à rejeter");
  }

  // ── 2b. AUTO-REJECT GLOBAL : rejette les demandes PENDING sur parties démarrées ─
  console.log("\n🚫  Nettoyage des demandes sur parties démarrées/terminées...");

  const pendingOnStartedGames = await prisma.participation.findMany({
    where: {
      status: "PENDING",
      game: { scheduledAt: { lt: now } },
    },
    select: { id: true },
  });

  if (pendingOnStartedGames.length > 0) {
    await prisma.participation.updateMany({
      where: { id: { in: pendingOnStartedGames.map((p) => p.id) } },
      data: { status: "REJECTED" },
    });
    console.log(
      `  ✓  ${pendingOnStartedGames.length} demande(s) rejetée(s) (parties déjà commencées)`,
    );
  } else {
    console.log("  ✓  Aucune demande orpheline");
  }

  // ── 3. REPLENISH : recrée des parties si sous le seuil par ville ─────────────
  console.log("\n📍  Vérification des villes...");

  let totalCreated = 0;

  for (const city of CITIES) {
    const openCount = await prisma.game.count({
      where: {
        creatorId: { in: npcUserIds },
        status: "OPEN",
        scheduledAt: { gte: now, lte: horizonEnd },
        latitude: {
          gte: city.lat - CITY_RADIUS_DEG,
          lte: city.lat + CITY_RADIUS_DEG,
        },
        longitude: {
          gte: city.lng - CITY_RADIUS_DEG,
          lte: city.lng + CITY_RADIUS_DEG,
        },
      },
    });

    if (openCount < MIN_OPEN_GAMES_PER_CITY) {
      const toCreate =
        MIN_OPEN_GAMES_PER_CITY - openCount + NEW_GAMES_PER_REPLENISH;
      console.log(
        `  ⚠️  ${city.name} : ${openCount}/${MIN_OPEN_GAMES_PER_CITY} parties → création de ${toCreate}`,
      );

      for (let i = 0; i < toCreate; i++) {
        const creator =
          npcUserIds[Math.floor(Math.random() * npcUserIds.length)];
        const venue = pick(city.venues);
        const gameType = pick(GAME_TYPES);
        const { maxPlayers, duration } = gameConfig(gameType);
        const coords = jitter(city.lat, city.lng);
        // Planifie au-delà de l'horizon actuel pour ne pas gonfler trop vite
        const daysAhead = HORIZON_DAYS + 1 + i;

        await prisma.game.create({
          data: {
            gameType,
            description: pick(GAME_DESCRIPTIONS[gameType]),
            address: venue.address,
            latitude: coords.lat,
            longitude: coords.lng,
            scheduledAt: futureDate(daysAhead),
            duration,
            maxPlayers,
            status: "OPEN",
            creatorId: creator,
          },
        });
        totalCreated++;
      }
    } else {
      console.log(`  ✓  ${city.name} : ${openCount} parties OPEN (OK)`);
    }
  }

  // ── RÉSUMÉ ───────────────────────────────────────────────────────────────────
  console.log(
    "\n══════════════════════════════════════════════════════════════",
  );
  console.log(`✅  Cron terminé — ${new Date().toLocaleString("fr-FR")}`);
  if (totalCreated > 0)
    console.log(`   +${totalCreated} nouvelle(s) partie(s) créée(s)`);
  console.log(
    "══════════════════════════════════════════════════════════════\n",
  );
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
