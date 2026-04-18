/**
 * npc_config.js — Configuration centralisée du seed content NPC
 *
 * ⚠️  METTRE À JOUR avant le lancement :
 *   - Confirmer les villes avec le client (CITIES)
 *   - Ajuster MIN_OPEN_GAMES_PER_CITY selon la densité voulue
 *
 * Pour ajouter une ville :
 *   1. Ajouter une entrée dans CITIES avec lat/lng/venues
 *   2. Relancer : node scripts/seed_launch.js --force
 */

// Suffixe email qui identifie tous les comptes NPC
export const NPC_EMAIL_SUFFIX = "@npc.duelfinder.com";

// ─── VILLES ──────────────────────────────────────────────────────────────────
// slots : jours auxquels des parties seront créées au lancement (seed_launch.js)
// Plus de slots = plus de présence dans cette ville
export const CITIES = [
  {
    id: "paris",
    name: "Paris",
    lat: 48.8566,
    lng: 2.3522,
    // Présence forte — 18 slots sur 30 jours
    slots: [1, 2, 3, 4, 5, 7, 8, 10, 12, 14, 15, 17, 19, 21, 23, 25, 27, 30],
    venues: [
      { address: "Place de la République, 75010 Paris" },
      { address: "Rue Oberkampf 42, 75011 Paris" },
      { address: "Rue de Rivoli 18, 75001 Paris" },
      { address: "Boulevard Beaumarchais 56, 75011 Paris" },
      { address: "Rue Saint-Denis 90, 75002 Paris" },
      { address: "Place de la Bastille, 75011 Paris" },
      { address: "Rue Montmartre 35, 75001 Paris" },
      { address: "Rue de la Roquette 74, 75011 Paris" },
    ],
  },
  {
    id: "bruxelles",
    name: "Bruxelles",
    lat: 50.8503,
    lng: 4.3517,
    // Présence modérée — 10 slots sur 30 jours
    slots: [1, 3, 6, 8, 12, 15, 18, 22, 26, 29],
    venues: [
      { address: "Rue Neuve 45, 1000 Bruxelles" },
      { address: "Boulevard Adolphe Max 12, 1000 Bruxelles" },
      { address: "Chaussée d'Ixelles 82, 1050 Bruxelles" },
    ],
  },
  {
    id: "charleroi",
    name: "Charleroi",
    lat: 50.4108,
    lng: 4.4445,
    // Présence modérée — 10 slots sur 30 jours
    slots: [1, 3, 5, 8, 10, 14, 17, 20, 25, 29],
    venues: [
      { address: "Rue de la Montagne 8, 6000 Charleroi" },
      { address: "Boulevard Tirou 15, 6000 Charleroi" },
      { address: "Place Charles II, 6000 Charleroi" },
      { address: "Rue du Commerce 22, 6000 Charleroi" },
    ],
  },
];

// ─── PROFILS NPC ──────────────────────────────────────────────────────────────
// 20 profils réalistes de joueurs TCG belges francophones
export const NPC_PROFILES = [
  { username: "PixelDuelist",  bio: "Joueur compétitif Pokémon VGC. Top 16 régionale 2024.",              badgeLevel: "GOLD",   totalGamesPlayed: 94  },
  { username: "CardSamurai",   bio: "YGO format Advanced depuis 2015. Master Duel IRL only.",              badgeLevel: "GOLD",   totalGamesPlayed: 112 },
  { username: "BelgaTCG",      bio: "Multi-jeux : Pokémon, One Piece, YGO. Niveau intermédiaire.",        badgeLevel: "SILVER", totalGamesPlayed: 45  },
  { username: "LucieDuel",     bio: "One Piece TCG depuis le set OP-01. Fan des decks Nami.",              badgeLevel: "SILVER", totalGamesPlayed: 38  },
  { username: "KaijuDeck",     bio: "YGO compétitif, spécialiste combo. ROTA > tout.",                    badgeLevel: "GOLD",   totalGamesPlayed: 78  },
  { username: "PokeFanBE",     bio: "Collectionneur et joueur casual Pokémon. Tous formats.",              badgeLevel: null,     totalGamesPlayed: 12  },
  { username: "NarutoSensei",  bio: "Naruto TCG depuis le début. J'ai tous les sets originaux.",           badgeLevel: "GOLD",   totalGamesPlayed: 130 },
  { username: "Maxou_TCG",     bio: "Pokémon Expanded, deck Gardevoir ex. Cherche parties sérieuses.",    badgeLevel: "SILVER", totalGamesPlayed: 57  },
  { username: "OnePieceBE",    bio: "Deck Luffy ST-01 modifié. Toujours là pour des sessions fun.",       badgeLevel: "BRONZE", totalGamesPlayed: 23  },
  { username: "DuelMaster99",  bio: "Vétéran YGO depuis l'ère Goat. Je connais toutes les errata.",       badgeLevel: "GOLD",   totalGamesPlayed: 201 },
  { username: "SylviaCards",   bio: "Joueuse Pokémon format Standard. Spécialiste decks rapides.",        badgeLevel: "SILVER", totalGamesPlayed: 41  },
  { username: "GhostRiderTCG", bio: "Naruto TCG + One Piece. J'amène toujours des snacks.",               badgeLevel: "BRONZE", totalGamesPlayed: 29  },
  { username: "TCGHunter",     bio: "Je chasse les cartes rares et je les joue. Format libre only.",      badgeLevel: "SILVER", totalGamesPlayed: 63  },
  { username: "ZoroSwords",    bio: "One Piece TCG Zoro control. Parties longues et tactiques.",           badgeLevel: "SILVER", totalGamesPlayed: 47  },
  { username: "PikaMaster_BE", bio: "Pokémon depuis la Base Set. Mon premier deck : Dracaufeu.",           badgeLevel: "GOLD",   totalGamesPlayed: 155 },
  { username: "YugiBoomer",    bio: "YGO depuis 2002. Format Goat préféré, old school forever.",          badgeLevel: "GOLD",   totalGamesPlayed: 189 },
  { username: "CasualCardFan", bio: "Joueur casual cherchant parties détendues. Tous les TCG.",            badgeLevel: null,     totalGamesPlayed: 8   },
  { username: "NinjaOfCards",  bio: "Naruto TCG + YGO. Deck ninja pour les deux.",                        badgeLevel: "BRONZE", totalGamesPlayed: 19  },
  { username: "LouiseTCG",     bio: "Pokémon compétitif, équipe junior 2023. Niveau expert.",              badgeLevel: "GOLD",   totalGamesPlayed: 88  },
  { username: "DraftKing_BE",  bio: "Draft Pokémon specialist. J'organise des draftings chaque semaine.", badgeLevel: "SILVER", totalGamesPlayed: 72  },
];

// ─── DESCRIPTIONS DE PARTIES ──────────────────────────────────────────────────
export const GAME_DESCRIPTIONS = {
  POKEMON: [
    "Format Standard, niveau intermédiaire bienvenu. On joue pour le fun !",
    "Draft Pokémon ! On se partage les boosters, format libre ensuite.",
    "Decks construits uniquement. Niveau débutant/intermédiaire.",
    "Format Expanded, cherche adversaire expérimenté.",
    "Session Pokémon décontractée, tous niveaux bienvenus.",
    "Mini tournoi round-robin 4 joueurs. Decks construits.",
    "Pokémon compétitif Standard. Bring your best deck !",
    "Session d'entraînement avant la prochaine régionale.",
  ],
  YUGIOH: [
    "Format Advanced, amène ton side deck !",
    "Duel BO3, niveau intermédiaire. Pas de FTK svp.",
    "YGO débutant friendly, on peut expliquer les règles.",
    "Format Master Duel IRL. Deck combo bienvenu.",
    "Session YGO old school, format Goat ou Advanced.",
    "Casual YGO, tous decks acceptés.",
    "Tournoi BO3 avec side deck. Format Advanced.",
  ],
  ONE_PIECE: [
    "One Piece TCG set OP-07 autorisé. Niveau intermédiaire.",
    "Session One Piece débutant, on peut prêter des decks.",
    "Tournoi 4 joueurs round-robin One Piece TCG.",
    "One Piece TCG, échange de cartes possible après !",
    "Set OP-08 bienvenu. Cherche joueurs sérieux.",
    "Session fun One Piece, ambiance décontractée.",
  ],
  NARUTO: [
    "Naruto TCG old school, j'ai des decks de prêt si besoin.",
    "Session Naruto TCG tous niveaux. On boit un café en jouant.",
    "Naruto TCG, format libre. Venez avec vos decks persos.",
    "Casual Naruto TCG, ambiance décontractée garantie.",
  ],
};

// ─── MESSAGES DE CHAT ─────────────────────────────────────────────────────────
// Utilisés pour peupler les chats des parties FULL
export const CHAT_MESSAGES = [
  "Salut ! On se retrouve bien à l'adresse indiquée ?",
  "Oui, j'arrive un peu avant pour prendre une table.",
  "J'amène mon deck habituel, on va faire de belles parties !",
  "C'est quoi le format exact aujourd'hui ?",
  "Format libre, decks construits. À tout à l'heure !",
  "Super, hâte d'être là.",
  "Je serai là pile à l'heure, deck prêt.",
  "On note les scores ou c'est juste pour le fun ?",
  "Pour le fun, mais je vais quand même essayer de gagner haha",
  "Haha pareil. À tout à l'heure !",
];

// ─── PARAMÈTRES DU CRON ───────────────────────────────────────────────────────
export const CRON_CONFIG = {
  // Nombre minimum de parties OPEN NPC par ville dans les X prochains jours
  MIN_OPEN_GAMES_PER_CITY: 3,
  // Fenêtre de vérification en jours
  HORIZON_DAYS: 7,
  // Nombre de parties à créer si sous le seuil
  NEW_GAMES_PER_REPLENISH: 2,
  // Rejeter les demandes PENDING de vrais users sur parties NPC après X heures
  AUTO_REJECT_AFTER_HOURS: 12,
  // Rayon en degrés pour identifier les parties d'une ville (≈15km)
  CITY_RADIUS_DEG: 0.15,
};
