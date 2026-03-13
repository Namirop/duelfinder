/**
 * Seed DuelFinder — données de test réalistes
 *
 * Comptes principaux :
 *   romain@duelfinder.com  / password123  → Romain-TCG
 *   dev@duelfinder.com     / password123  → Dev1234
 *
 * Run : npm run prisma:seed
 */

import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();
const hash = (pw) => bcrypt.hashSync(pw, 10);
const avatar = (seed) =>
  `https://api.dicebear.com/7.x/avataaars/png?seed=${encodeURIComponent(seed)}`;

// Helpers temporels
const now = new Date();
const inH = (h) => new Date(now.getTime() + h * 3_600_000);
const agoH = (h) => new Date(now.getTime() - h * 3_600_000);
const inD = (d) => inH(d * 24);

async function main() {
  // ── 1. CLEAN ─────────────────────────────────────────────────────────────
  await prisma.notification.deleteMany();
  await prisma.message.deleteMany();
  await prisma.participation.deleteMany();
  await prisma.game.deleteMany();
  await prisma.user.deleteMany();
  console.log("🗑️  Base vidée");

  // ── 2. USERS ──────────────────────────────────────────────────────────────
  const [romain, dev, lucas, emma, theo, sakura, zack, nina] =
    await Promise.all([
      // ★ Compte 1 — émulateur principal
      prisma.user.create({
        data: {
          email: "romain@duelfinder.com",
          passwordHash: hash("password123"),
          username: "Romain-TCG",
          bio: "Joueur Pokémon depuis 2010, fan de draft et de tournois locaux. Toujours partant pour une petite session !",
          avatar: avatar("Romain-TCG"),
          totalGamesPlayed: 42,
          badgeLevel: "GOLD",
        },
      }),
      // ★ Compte 2 — deuxième émulateur
      prisma.user.create({
        data: {
          email: "dev@duelfinder.com",
          passwordHash: hash("password123"),
          username: "Dev1234",
          bio: "Testeur officiel de l'app. Je joue à tout, partout, tout le temps.",
          avatar: avatar("Dev1234"),
          totalGamesPlayed: 17,
          badgeLevel: "BRONZE",
        },
      }),
      // NPC accounts
      prisma.user.create({
        data: {
          email: "lucas@example.com",
          passwordHash: hash("password123"),
          username: "LucasYugi",
          bio: "Maître du deck Blue-Eyes. Challenge accepted 👁️",
          avatar: avatar("LucasYugi"),
          totalGamesPlayed: 28,
          badgeLevel: "SILVER",
        },
      }),
      prisma.user.create({
        data: {
          email: "emma@example.com",
          passwordHash: hash("password123"),
          username: "EmmaOnePiece",
          bio: "One Piece TCG seulement. Cherche adversaires sérieux pour améliorer mon deck Luffy.",
          avatar: avatar("EmmaOnePiece"),
          totalGamesPlayed: 15,
          badgeLevel: "BRONZE",
        },
      }),
      prisma.user.create({
        data: {
          email: "theo@example.com",
          passwordHash: hash("password123"),
          username: "TheoNaruto",
          bio: "Naruto TCG old school. J'ai tous les sets depuis le début.",
          avatar: avatar("TheoNaruto"),
          totalGamesPlayed: 67,
          badgeLevel: "GOLD",
        },
      }),
      prisma.user.create({
        data: {
          email: "sakura@example.com",
          passwordHash: hash("password123"),
          username: "SakuraPika",
          bio: "Collectionneuse et joueuse casual Pokémon. Je joue pour le fun !",
          avatar: avatar("SakuraPika"),
          totalGamesPlayed: 9,
          badgeLevel: null,
        },
      }),
      prisma.user.create({
        data: {
          email: "zack@example.com",
          passwordHash: hash("password123"),
          username: "ZackDuel",
          bio: "Multi-jeux : Pokémon, Yu-Gi-Oh!, One Piece. Niveau intermédiaire sur tous.",
          avatar: avatar("ZackDuel"),
          totalGamesPlayed: 33,
          badgeLevel: "SILVER",
        },
      }),
      prisma.user.create({
        data: {
          email: "nina@example.com",
          passwordHash: hash("password123"),
          username: "NinaCards",
          bio: "Joueuse compétitive Pokémon VGC & TCG. Top 8 régionale 2024 🏆",
          avatar: avatar("NinaCards"),
          totalGamesPlayed: 58,
          badgeLevel: "GOLD",
        },
      }),
    ]);

  console.log("👥  Utilisateurs créés (8)");

  // ── 3. GAMES ──────────────────────────────────────────────────────────────
  // Centrées sur Paris, bien espacées pour la map
  const games = await Promise.all([
    // ── G1 : OPEN Pokémon — créée par ROMAIN → Dev peut envoyer une demande
    prisma.game.create({
      data: {
        gameType: "POKEMON",
        description:
          "Format Standard, decks construits. Niveau intermédiaire bienvenu, débutants OK si motivés !",
        address: "Centre Commercial Rive Gauche, 6000 Charleroi",
        latitude: 50.4108,
        longitude: 4.4445,
        scheduledAt: inH(3),
        duration: 120,
        maxPlayers: 4,
        status: "OPEN",
        creatorId: romain.id,
      },
    }),

    // ── G2 : OPEN Pokémon — créée par ROMAIN → 1 demande PENDING (ZackDuel)
    // → pour tester le "Game Requests Sheet" de Romain
    prisma.game.create({
      data: {
        gameType: "POKEMON",
        description:
          "Draft Pokémon ! On se partage les boosters, format libre ensuite.",
        address: "Place Charles II, 6000 Charleroi",
        latitude: 50.4117,
        longitude: 4.443,
        scheduledAt: inD(2),
        duration: 180,
        maxPlayers: 4,
        status: "OPEN",
        creatorId: romain.id,
      },
    }),

    // ── G3 : FULL Pokémon — créée par ROMAIN → Dev est ACCEPTED
    // → romain voit cette partie dans "mes parties" (FULL)
    // → dev a une conversation active
    prisma.game.create({
      data: {
        gameType: "POKEMON",
        description:
          "Mini tournoi 4 joueurs, round-robin. On se retrouve au café.",
        address: "Rue de la Montagne, 6000 Charleroi",
        latitude: 50.4095,
        longitude: 4.4462,
        scheduledAt: inH(6),
        duration: 180,
        maxPlayers: 4,
        status: "FULL",
        wasFilledOnce: true,
        creatorId: romain.id,
      },
    }),

    // ── G4 : OPEN Yu-Gi-Oh! — créée par DEV → Romain a envoyé une demande PENDING
    // → Dev reçoit une notif de demande de Romain
    prisma.game.create({
      data: {
        gameType: "YUGIOH",
        description: "Duel BO3, format Advanced. Amène ton side deck !",
        address: "Place du Manège, 6000 Charleroi",
        latitude: 50.408,
        longitude: 4.448,
        scheduledAt: inH(5),
        duration: 90,
        maxPlayers: 2,
        status: "OPEN",
        creatorId: dev.id,
      },
    }),

    // ── G5 : OPEN One Piece — créée par DEV → Romain est ACCEPTED
    // → conversation active entre Romain et Dev
    prisma.game.create({
      data: {
        gameType: "ONE_PIECE",
        description:
          "Session One Piece TCG débutant/intermédiaire. Échange de cartes possible après !",
        address: "Place Fernand Golenvaux, 6020 Montignies-sur-Sambre",
        latitude: 50.403,
        longitude: 4.472,
        scheduledAt: inD(1),
        duration: 90,
        maxPlayers: 3,
        status: "OPEN",
        creatorId: dev.id,
      },
    }),

    // ── G6 : OPEN Naruto — créée par THEO
    prisma.game.create({
      data: {
        gameType: "NARUTO",
        description:
          "Naruto TCG old school, j'ai des decks de prêt si t'as pas le tien.",
        address: "Grand Place de Gosselies, 6041 Gosselies",
        latitude: 50.457,
        longitude: 4.453,
        scheduledAt: inH(8),
        duration: 90,
        maxPlayers: 2,
        status: "OPEN",
        creatorId: theo.id,
      },
    }),

    // ── G7 : OPEN Yu-Gi-Oh! — créée par LUCAS
    prisma.game.create({
      data: {
        gameType: "YUGIOH",
        description:
          "Format Master Duel IRL. Deck combo bienvenu, niveau expert.",
        address: "Place Communale de Jumet, 6040 Jumet",
        latitude: 50.436,
        longitude: 4.421,
        scheduledAt: inH(10),
        duration: 120,
        maxPlayers: 2,
        status: "OPEN",
        creatorId: lucas.id,
      },
    }),

    // ── G8 : FULL One Piece — créée par EMMA
    prisma.game.create({
      data: {
        gameType: "ONE_PIECE",
        description:
          "Tournoi 4 joueurs round-robin One Piece TCG. Set OP-07 autorisé.",
        address: "Rue de Gilly, 6060 Gilly",
        latitude: 50.401,
        longitude: 4.469,
        scheduledAt: inD(3),
        duration: 240,
        maxPlayers: 4,
        status: "FULL",
        wasFilledOnce: true,
        creatorId: emma.id,
      },
    }),

    // ── G9 : OPEN Pokémon — créée par NINA
    prisma.game.create({
      data: {
        gameType: "POKEMON",
        description:
          "Format Expanded, niveau compétitif. Cherche joueur expérimenté.",
        address: "Place Albert Ier, 6030 Marchienne-au-Pont",
        latitude: 50.405,
        longitude: 4.408,
        scheduledAt: inD(1),
        duration: 120,
        maxPlayers: 2,
        status: "OPEN",
        creatorId: nina.id,
      },
    }),

    // ── G10 : OPEN Naruto — créée par SAKURA
    prisma.game.create({
      data: {
        gameType: "NARUTO",
        description:
          "Casual Naruto TCG, tous niveaux bienvenus. On boit un café en jouant.",
        address: "Rue du Grand Lodelinsart, 6010 Couillet",
        latitude: 50.426,
        longitude: 4.422,
        scheduledAt: inH(12),
        duration: 60,
        maxPlayers: 2,
        status: "OPEN",
        creatorId: sakura.id,
      },
    }),

    // ── G11 : OPEN Yu-Gi-Oh! — créée par ZACK
    prisma.game.create({
      data: {
        gameType: "YUGIOH",
        description:
          "YGO débutant friendly, on peut expliquer les règles si besoin.",
        address: "Rue de Couillet, 6010 Couillet",
        latitude: 50.398,
        longitude: 4.456,
        scheduledAt: inH(24),
        duration: 90,
        maxPlayers: 2,
        status: "OPEN",
        creatorId: zack.id,
      },
    }),

    // ── G12 : CANCELLED Pokémon — créée par SAKURA (pour "mes parties" annulées)
    prisma.game.create({
      data: {
        gameType: "POKEMON",
        description: "Session annulée suite à indisponibilité.",
        address: "Avenue de Ransart, 6020 Ransart",
        latitude: 50.429,
        longitude: 4.435,
        scheduledAt: agoH(2),
        duration: 90,
        maxPlayers: 2,
        status: "CANCELLED",
        creatorId: sakura.id,
      },
    }),
  ]);

  const [g1, g2, g3, g4, g5, g6, g7, g8, g9, g10, g11, g12] = games;
  console.log("🎮  Parties créées (12)");

  // ── 4. PARTICIPATIONS ────────────────────────────────────────────────────

  // G1 (OPEN Pokémon Marais, max 4, par Romain) — ZackDuel ACCEPTED, SakuraPika PENDING
  const [pG1Zack, pG1Sakura] = await Promise.all([
    prisma.participation.create({
      data: {
        userId: zack.id,
        gameId: g1.id,
        status: "ACCEPTED",
        acceptedAt: agoH(2),
      },
    }),
    prisma.participation.create({
      data: { userId: sakura.id, gameId: g1.id, status: "PENDING" },
    }),
  ]);

  // G2 (OPEN Pokémon Draft République, max 4, par Romain) — NinaCards PENDING, Dev1234 PENDING
  // → Romain a 2 demandes en attente à traiter
  const [pG2Nina, pG2Dev] = await Promise.all([
    prisma.participation.create({
      data: { userId: nina.id, gameId: g2.id, status: "PENDING" },
    }),
    prisma.participation.create({
      data: { userId: dev.id, gameId: g2.id, status: "PENDING" },
    }),
  ]);

  // G3 (FULL Pokémon Oberkampf, max 4, par Romain) — Dev+Lucas+Emma ACCEPTED
  const [pG3Dev, pG3Lucas, pG3Emma] = await Promise.all([
    prisma.participation.create({
      data: {
        userId: dev.id,
        gameId: g3.id,
        status: "ACCEPTED",
        acceptedAt: agoH(8),
      },
    }),
    prisma.participation.create({
      data: {
        userId: lucas.id,
        gameId: g3.id,
        status: "ACCEPTED",
        acceptedAt: agoH(7),
      },
    }),
    prisma.participation.create({
      data: {
        userId: emma.id,
        gameId: g3.id,
        status: "ACCEPTED",
        acceptedAt: agoH(6),
      },
    }),
  ]);

  // G4 (OPEN YGO Bastille, max 2, par Dev) — Romain PENDING
  // → Dev voit la demande de Romain dans son Game Requests Sheet
  const [pG4Romain] = await Promise.all([
    prisma.participation.create({
      data: { userId: romain.id, gameId: g4.id, status: "PENDING" },
    }),
  ]);

  // G5 (OPEN One Piece Montmartre, max 3, par Dev) — Romain ACCEPTED, Theo ACCEPTED
  // → Romain et Dev ont une conversation active
  const [pG5Romain, pG5Theo] = await Promise.all([
    prisma.participation.create({
      data: {
        userId: romain.id,
        gameId: g5.id,
        status: "ACCEPTED",
        acceptedAt: agoH(12),
      },
    }),
    prisma.participation.create({
      data: {
        userId: theo.id,
        gameId: g5.id,
        status: "ACCEPTED",
        acceptedAt: agoH(11),
      },
    }),
  ]);

  // G7 (OPEN YGO Opéra, max 2, par Lucas) — Sakura REJECTED
  await prisma.participation.create({
    data: { userId: sakura.id, gameId: g7.id, status: "REJECTED" },
  });

  // G8 (FULL One Piece Belleville, max 4, par Emma) — Romain+Lucas+Zack ACCEPTED
  await Promise.all([
    prisma.participation.create({
      data: {
        userId: romain.id,
        gameId: g8.id,
        status: "ACCEPTED",
        acceptedAt: agoH(20),
      },
    }),
    prisma.participation.create({
      data: {
        userId: lucas.id,
        gameId: g8.id,
        status: "ACCEPTED",
        acceptedAt: agoH(18),
      },
    }),
    prisma.participation.create({
      data: {
        userId: zack.id,
        gameId: g8.id,
        status: "ACCEPTED",
        acceptedAt: agoH(15),
      },
    }),
  ]);

  console.log("🤝  Participations créées");

  // ── 5. MESSAGES ──────────────────────────────────────────────────────────

  // G3 — Chat du tournoi Romain (FULL Pokémon Oberkampf) : Romain + Dev + Lucas
  await prisma.message.createMany({
    data: [
      {
        gameId: g3.id,
        senderId: romain.id,
        content:
          "Salut tout le monde ! On se retrouve au café Oberkampf, y'a une grande table au fond.",
        createdAt: agoH(7.5),
      },
      {
        gameId: g3.id,
        senderId: dev.id,
        content: "Parfait, j'arrive vers 14h. J'amène mon deck Charizard ex.",
        createdAt: agoH(7.3),
      },
      {
        gameId: g3.id,
        senderId: lucas.id,
        content: "Okay pour moi aussi. Je joue un Blue-Eyes surprise 👁️",
        createdAt: agoH(7.1),
      },
      {
        gameId: g3.id,
        senderId: romain.id,
        content: "Haha la surprise on verra ça sur table. Emma tu joues quoi ?",
        createdAt: agoH(7.0),
      },
      {
        gameId: g3.id,
        senderId: emma.id,
        content:
          "Un deck Luffy tcg pour changer un peu 😄 Ça compte pas hein c'est pour rire",
        createdAt: agoH(6.8),
      },
      {
        gameId: g3.id,
        senderId: dev.id,
        content: "Lol, on accepte tout. Hâte de voir ça !",
        createdAt: agoH(6.5),
      },
      {
        gameId: g3.id,
        senderId: romain.id,
        content:
          "Bon on fait ça en round-robin ? Chacun joue contre chacun, 2 sets par match.",
        createdAt: agoH(5.0),
      },
      {
        gameId: g3.id,
        senderId: dev.id,
        content: "Oui carrément. On note les scores ?",
        createdAt: agoH(4.8),
      },
      {
        gameId: g3.id,
        senderId: lucas.id,
        content: "Je prends un tableau sur mon tel. Plus qu'à venir 🎴",
        createdAt: agoH(4.5),
      },
    ],
  });

  // G5 — Chat One Piece Montmartre : Dev + Romain + Theo
  await prisma.message.createMany({
    data: [
      {
        gameId: g5.id,
        senderId: dev.id,
        content:
          "Hey ! Je suis le créateur, on se retrouve à la Place du Tertre, y'a des tables dehors.",
        createdAt: agoH(11.5),
      },
      {
        gameId: g5.id,
        senderId: romain.id,
        content:
          "Nickel ! Je connais bien l'endroit. Vers quelle heure exactement ?",
        createdAt: agoH(11.2),
      },
      {
        gameId: g5.id,
        senderId: dev.id,
        content:
          "Demain 15h ça te va ? J'ai précisé dans la partie mais au cas où.",
        createdAt: agoH(11.0),
      },
      {
        gameId: g5.id,
        senderId: theo.id,
        content:
          "Moi je serai là. Je joue One Piece depuis peu donc soyez indulgents haha",
        createdAt: agoH(10.5),
      },
      {
        gameId: g5.id,
        senderId: romain.id,
        content:
          "Pas de souci Theo ! On est là pour jouer et rigoler. Tu connais les bases au moins ?",
        createdAt: agoH(10.2),
      },
      {
        gameId: g5.id,
        senderId: theo.id,
        content:
          "Oui oui les règles je les connais, juste que je maîtrise pas encore toutes les synergies.",
        createdAt: agoH(10.0),
      },
      {
        gameId: g5.id,
        senderId: dev.id,
        content: "Super, à demain alors ! Je serai en noir, chapeau rouge 🎩",
        createdAt: agoH(9.5),
      },
      {
        gameId: g5.id,
        senderId: romain.id,
        content: "Haha parfait, facile à repérer. À demain !",
        createdAt: agoH(9.0),
      },
    ],
  });

  // G1 — Chat Pokémon Marais : Romain + Zack (ZackDuel est ACCEPTED)
  await prisma.message.createMany({
    data: [
      {
        gameId: g1.id,
        senderId: zack.id,
        content: "Salut ! Je joue un deck Miraidon ex, ça te dérange pas ?",
        createdAt: agoH(2.5),
      },
      {
        gameId: g1.id,
        senderId: romain.id,
        content: "Pas du tout, j'ai un Charizard ex. Ça va être un bon match !",
        createdAt: agoH(2.3),
      },
      {
        gameId: g1.id,
        senderId: zack.id,
        content: "Top ! On se retrouve bien au café du coin de la rue ?",
        createdAt: agoH(2.1),
      },
      {
        gameId: g1.id,
        senderId: romain.id,
        content: "Ouais parfait, à tout à l'heure 👍",
        createdAt: agoH(2.0),
      },
    ],
  });

  console.log("💬  Messages créés");

  // ── 6. NOTIFICATIONS ─────────────────────────────────────────────────────

  // ── Pour ROMAIN ──
  await prisma.notification.createMany({
    data: [
      // Non lues (en haut, les plus récentes)
      {
        userId: romain.id,
        type: "PARTICIPATION_REQUEST",
        title: "Nouvelle demande",
        body: "NinaCards veut rejoindre votre partie Draft Pokémon à République.",
        read: false,
        createdAt: agoH(0.3),
        data: { gameId: g2.id, participationId: pG2Nina.id },
      },
      {
        userId: romain.id,
        type: "PARTICIPATION_REQUEST",
        title: "Nouvelle demande",
        body: "Dev1234 veut rejoindre votre partie Draft Pokémon à République.",
        read: false,
        createdAt: agoH(0.8),
        data: { gameId: g2.id, participationId: pG2Dev.id },
      },
      {
        userId: romain.id,
        type: "PARTICIPATION_REQUEST",
        title: "Nouvelle demande",
        body: "SakuraPika veut rejoindre votre partie Pokémon au Marais.",
        read: false,
        createdAt: agoH(1.2),
        data: { gameId: g1.id, participationId: pG1Sakura.id },
      },
      {
        userId: romain.id,
        type: "NEW_MESSAGE",
        title: "Nouveau message — One Piece Montmartre",
        body: 'Dev1234 : "Super, à demain alors ! Je serai en noir, chapeau rouge 🎩"',
        read: false,
        createdAt: agoH(9.5),
        data: { gameId: g5.id },
      },
      // Lues (historique)
      {
        userId: romain.id,
        type: "PARTICIPATION_ACCEPTED",
        title: "Demande acceptée !",
        body: "Dev1234 a accepté votre demande pour la partie One Piece à Montmartre.",
        read: true,
        createdAt: agoH(12),
        data: { gameId: g5.id },
      },
      {
        userId: romain.id,
        type: "GAME_FULL",
        title: "Partie complète !",
        body: "Votre partie Pokémon à Oberkampf est maintenant complète. C'est parti !",
        read: true,
        createdAt: agoH(6),
        data: { gameId: g3.id },
      },
      {
        userId: romain.id,
        type: "PARTICIPATION_ACCEPTED",
        title: "Demande acceptée !",
        body: "Votre demande pour la partie One Piece à Belleville a été acceptée.",
        read: true,
        createdAt: agoH(20),
        data: { gameId: g8.id },
      },
      {
        userId: romain.id,
        type: "NEW_MESSAGE",
        title: "Nouveau message — Pokémon Marais",
        body: 'ZackDuel : "Salut ! Je joue un deck Miraidon ex, ça te dérange pas ?"',
        read: true,
        createdAt: agoH(2.5),
        data: { gameId: g1.id },
      },
    ],
  });

  // ── Pour DEV ──
  await prisma.notification.createMany({
    data: [
      // Non lues
      {
        userId: dev.id,
        type: "PARTICIPATION_REQUEST",
        title: "Nouvelle demande",
        body: "Romain-TCG veut rejoindre votre partie Yu-Gi-Oh! à Bastille.",
        read: false,
        createdAt: agoH(0.5),
        data: { gameId: g4.id, participationId: pG4Romain.id },
      },
      {
        userId: dev.id,
        type: "NEW_MESSAGE",
        title: "Nouveau message — Pokémon Oberkampf",
        body: 'Romain-TCG : "Haha la surprise on verra ça sur table. Emma tu joues quoi ?"',
        read: false,
        createdAt: agoH(7.0),
        data: { gameId: g3.id },
      },
      // Lues
      {
        userId: dev.id,
        type: "PARTICIPATION_ACCEPTED",
        title: "Demande acceptée !",
        body: "Romain-TCG a accepté votre demande pour la partie Pokémon à Oberkampf.",
        read: true,
        createdAt: agoH(8),
        data: { gameId: g3.id },
      },
      {
        userId: dev.id,
        type: "GAME_FULL",
        title: "Partie complète !",
        body: "La partie Pokémon à Oberkampf est maintenant complète. Prépare ton deck !",
        read: true,
        createdAt: agoH(6),
        data: { gameId: g3.id },
      },
      {
        userId: dev.id,
        type: "PARTICIPATION_ACCEPTED",
        title: "Vous rejoignez la partie !",
        body: "Votre participation à la partie Draft à République est en attente de validation.",
        read: true,
        createdAt: agoH(0.8),
        data: { gameId: g2.id },
      },
    ],
  });

  console.log("🔔  Notifications créées");

  // ── 7. RÉSUMÉ ─────────────────────────────────────────────────────────────
  console.log(
    "\n══════════════════════════════════════════════════════════════",
  );
  console.log("✅  SEED TERMINÉ\n");
  console.log("📱  COMPTES PRINCIPAUX\n");
  console.log("  Émulateur 1 (Romain-TCG)");
  console.log("    Email    : romain@duelfinder.com");
  console.log("    Password : password123");
  console.log("    Badges   : GOLD | 42 parties jouées\n");
  console.log("  Émulateur 2 (Dev1234)");
  console.log("    Email    : dev@duelfinder.com");
  console.log("    Password : password123");
  console.log("    Badges   : BRONZE | 17 parties jouées\n");
  console.log("🎮  PARTIES SUR LA MAP (12 au total)\n");
  console.log("  G1  Pokémon  OPEN   Marais         +3h   (par Romain)");
  console.log(
    "  G2  Pokémon  OPEN   République     +48h  (par Romain) ← 2 demandes PENDING",
  );
  console.log(
    "  G3  Pokémon  FULL   Oberkampf      +6h   (par Romain) ← Dev ACCEPTED → chat actif",
  );
  console.log(
    "  G4  YGO      OPEN   Bastille       +5h   (par Dev)    ← Romain PENDING",
  );
  console.log(
    "  G5  OnePiece OPEN   Montmartre     +24h  (par Dev)    ← Romain ACCEPTED → chat actif",
  );
  console.log("  G6  Naruto   OPEN   Nation         +8h   (par Theo)");
  console.log("  G7  YGO      OPEN   Opéra          +10h  (par Lucas)");
  console.log(
    "  G8  OnePiece FULL   Belleville     +72h  (par Emma)   ← Romain ACCEPTED",
  );
  console.log("  G9  Pokémon  OPEN   Luxembourg     +24h  (par Nina)");
  console.log("  G10 Naruto   OPEN   St-Germain     +12h  (par Sakura)");
  console.log("  G11 YGO      OPEN   Les Halles     +24h  (par Zack)");
  console.log("  G12 Pokémon  CANCEL Châtelet       -2h   (par Sakura)\n");
  console.log("🔔  NOTIFICATIONS\n");
  console.log(
    "  Romain : 4 non lues (2× demandes G2, 1× demande G1, 1× message G5)",
  );
  console.log("  Dev    : 2 non lues (demande de Romain G4, message G3)\n");
  console.log("💬  CONVERSATIONS ACTIVES\n");
  console.log(
    "  G3 Pokémon Oberkampf   → Romain + Dev + Lucas + Emma (9 messages)",
  );
  console.log("  G5 One Piece Montmartre → Dev + Romain + Theo (8 messages)");
  console.log("  G1 Pokémon Marais      → Romain + Zack (4 messages)");
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
