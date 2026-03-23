/**
 * cleanup_ghost.js — Suppression complète du seed content NPC
 *
 * À utiliser quand l'app a suffisamment de vrais utilisateurs
 * et qu'on n'a plus besoin du contenu fictif.
 *
 * Dry run (affiche sans supprimer) :  node scripts/cleanup_ghost.js
 * Suppression réelle :                node scripts/cleanup_ghost.js --force
 */

import { PrismaClient } from "@prisma/client";
import { NPC_EMAIL_SUFFIX } from "./npc_config.js";

const prisma = new PrismaClient();

async function main() {
  const isDryRun = !process.argv.includes("--force");

  console.log("\n🔍  CLEANUP GHOST CONTENT — DuelFinder\n");

  if (isDryRun) {
    console.log("  Mode : DRY RUN (aucune modification — utilisez --force pour supprimer réellement)\n");
  } else {
    console.log("  Mode : SUPPRESSION RÉELLE\n");
  }

  // 1. Identifie tous les users NPC
  const npcUsers = await prisma.user.findMany({
    where: { email: { endsWith: NPC_EMAIL_SUFFIX } },
    select: { id: true, username: true, email: true },
  });

  if (npcUsers.length === 0) {
    console.log("✓  Aucun compte NPC trouvé. La base ne contient que de vrais utilisateurs.\n");
    return;
  }

  const npcUserIds = npcUsers.map((u) => u.id);

  // 2. Identifie toutes les parties NPC
  const npcGames = await prisma.game.findMany({
    where: { creatorId: { in: npcUserIds } },
    select: { id: true },
  });
  const npcGameIds = npcGames.map((g) => g.id);

  // 3. Compte les entités liées
  const [msgCount, partCount, notifCount] = await Promise.all([
    prisma.message.count({ where: { gameId: { in: npcGameIds } } }),
    prisma.participation.count({
      where: {
        OR: [
          { gameId: { in: npcGameIds } },
          { userId: { in: npcUserIds } },
        ],
      },
    }),
    prisma.notification.count({ where: { userId: { in: npcUserIds } } }),
  ]);

  // Résumé de ce qui sera supprimé
  console.log("📊  DONNÉES NPC IDENTIFIÉES\n");
  console.log(`  👥  Comptes NPC        : ${npcUsers.length}`);
  console.log(`  🎮  Parties NPC        : ${npcGames.length}`);
  console.log(`  💬  Messages           : ${msgCount}`);
  console.log(`  🤝  Participations     : ${partCount}`);
  console.log(`  🔔  Notifications      : ${notifCount}`);

  if (isDryRun) {
    console.log("\n💡  Lancez avec --force pour supprimer ces données définitivement.");
    console.log("    ⚠️  Cette action est irréversible.\n");
    return;
  }

  // 4. Suppression en cascade (ordre important pour les FK)
  console.log("\n🗑️  Suppression en cours...\n");

  await prisma.message.deleteMany({ where: { gameId: { in: npcGameIds } } });
  console.log(`  ✓  ${msgCount} messages supprimés`);

  await prisma.participation.deleteMany({
    where: {
      OR: [
        { gameId: { in: npcGameIds } },
        { userId: { in: npcUserIds } },
      ],
    },
  });
  console.log(`  ✓  ${partCount} participations supprimées`);

  await prisma.notification.deleteMany({ where: { userId: { in: npcUserIds } } });
  console.log(`  ✓  ${notifCount} notifications supprimées`);

  await prisma.game.deleteMany({ where: { id: { in: npcGameIds } } });
  console.log(`  ✓  ${npcGames.length} parties supprimées`);

  await prisma.user.deleteMany({ where: { id: { in: npcUserIds } } });
  console.log(`  ✓  ${npcUsers.length} comptes NPC supprimés`);

  console.log("\n✅  Nettoyage terminé. L'app ne contient plus que de vrais utilisateurs.\n");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
