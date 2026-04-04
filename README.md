# DuelFinder

Application mobile de mise en relation de joueurs de TCG (Trading Card Games). Trouvez des parties près de chez vous, rejoignez des sessions, et chattez avec d'autres joueurs en temps réel.

**Backend déployé sur Railway :** `https://duelfinder-production.up.railway.app/api`

---

## Fonctionnalités

- **Carte interactive** — Visualisez les parties ouvertes autour de vous (Mapbox)
- **Recherche géolocalisée** — Filtres par distance, type de jeu, créneau horaire
- **Création de partie** — Définissez lieu, date, durée et nombre de joueurs
- **Système de participation** — Demandez à rejoindre une partie, acceptation/refus par le créateur
- **Chat en temps réel** — Messagerie par partie entre participants
- **Notifications push** — Firebase Cloud Messaging pour les événements clés
- **Authentification** — Email/mot de passe + OAuth Facebook et Instagram
- **Profil & badges** — Historique de parties, niveaux Bronze/Silver/Gold
- **Anti-spam** — Limitation de créations et demandes de participation

---

## Jeux supportés

| Jeu | Couleur |
|-----|---------|
| Pokémon TCG | Jaune `#FFCC00` |
| Yu-Gi-Oh! | Or `#B8860B` |
| One Piece Card Game | Rouge `#E63946` |
| Naruto TCG | Orange `#FF6B35` |

---

## Stack technique

### Mobile — Flutter

| Outil | Rôle |
|-------|------|
| Flutter 3.2+ | Framework UI cross-platform |
| Riverpod 2.5 | State management |
| GoRouter 14 | Navigation déclarative |
| Dio 5 | Client HTTP + intercepteurs |
| Mapbox / Google Maps | Carte interactive |
| Firebase Messaging | Notifications push |
| Geolocator | Géolocalisation |
| flutter_secure_storage | Stockage sécurisé des tokens |
| Freezed + JsonSerializable | Modèles immuables + sérialisation |

### Backend — Node.js

| Outil | Rôle |
|-------|------|
| Node.js (ES Modules) | Runtime |
| Express.js 4 | Framework HTTP |
| Prisma 5 | ORM + migrations |
| PostgreSQL 16 | Base de données |
| JWT + bcrypt | Authentification |
| Firebase Admin | Envoi de notifications |
| express-validator | Validation des entrées |
| express-rate-limit | Protection anti-abus |

---

## Structure du projet

```
duelfinder/
├── app/                            # Application Flutter
│   ├── lib/
│   │   ├── main.dart               # Point d'entrée
│   │   ├── core/
│   │   │   ├── constants/          # URLs API, pagination, timeouts
│   │   │   ├── di/                 # Providers Riverpod globaux
│   │   │   ├── network/            # Client Dio, connectivité
│   │   │   ├── router/             # Configuration GoRouter
│   │   │   ├── services/           # Firebase, localisation, stockage
│   │   │   └── theme/              # Thème Material 3
│   │   ├── features/
│   │   │   ├── auth/               # Login, Register, Splash
│   │   │   ├── games/              # Création, liste de parties
│   │   │   ├── home/               # Écran carte + filtres
│   │   │   ├── messages/           # Conversations & chat
│   │   │   ├── notifications/      # Centre de notifications
│   │   │   ├── participations/     # Gestion des demandes
│   │   │   ├── profile/            # Profil & paramètres
│   │   │   ├── legal/              # CGU & politique de confidentialité
│   │   │   └── shell/              # Navigation principale (bottom nav)
│   │   └── shared/                 # Widgets réutilisables
│   ├── assets/images/              # Logos et icônes
│   └── android/                    # Config Android
│
└── backend/                        # API Node.js
    ├── src/
    │   ├── server.js               # Point d'entrée
    │   ├── app.js                  # Setup Express
    │   ├── config/                 # DB, Firebase, JWT
    │   ├── controllers/            # Handlers de routes
    │   ├── services/               # Logique métier
    │   ├── routes/                 # Définition des routes
    │   └── middlewares/            # Auth, erreurs, rate limiting
    ├── prisma/
    │   ├── schema.prisma           # Modèles de données
    │   ├── seed.js                 # Données de test
    │   └── migrations/             # Historique des migrations
    ├── scripts/
    │   ├── seed_launch.js          # Création des comptes NPC
    │   ├── cron_daily.js           # Tâches de maintenance quotidiennes
    │   ├── cleanup_ghost.js        # Nettoyage des données expirées
    │   └── npc_config.js           # Configuration des bots
    └── docker-compose.yml          # PostgreSQL local
```

---

## Modèles de données

### User
```
id, email, passwordHash, username, bio, avatar
fcmToken, facebookId, instagramId
role: USER | PARTNER | ADMIN
totalGamesPlayed, badgeLevel: BRONZE | SILVER | GOLD
```

### Game
```
id, gameType: POKEMON | YUGIOH | ONE_PIECE | NARUTO
address, latitude, longitude
scheduledAt, duration (minutes), maxPlayers
status: OPEN | FULL | CANCELLED
creatorId, wasFilledOnce
```

### Participation
```
id, status: PENDING | ACCEPTED | REJECTED | CANCELLED
userId, gameId (unique)
acceptedAt, lastReadAt
```

### Message
```
id, content, senderId, gameId, createdAt
```

### Notification
```
id, type, title, body, data (JSON), read
userId, createdAt
```

---

## API REST

### Auth — `/api/auth`
```
POST  /register       Créer un compte (limité : 10/15min)
POST  /login          Connexion email/mot de passe
POST  /facebook       OAuth Facebook
POST  /instagram      OAuth Instagram
POST  /refresh        Renouveler l'access token
GET   /me             Profil utilisateur connecté
```

### Utilisateurs — `/api/users`
```
GET    /me            Mon profil
PUT    /me            Modifier mon profil
PUT    /me/fcm-token  Mettre à jour le token Firebase
PUT    /me/password   Changer le mot de passe
DELETE /me            Supprimer le compte
GET    /:id           Profil public d'un utilisateur
```

### Parties — `/api/games`
```
GET  /existing                      Parties à proximité (auth optionnel)
                                    ?lat=&lng=&distance=&dateFrom=&dateTo=&gameType=
GET  /my-games                      Mes parties créées
POST /                              Créer une partie
DELETE /:gameId                     Annuler une partie

GET  /:gameId/participations        Demandes de participation
POST /:gameId/participations        Demander à rejoindre
GET  /:gameId/messages              Messages de la partie
POST /:gameId/messages              Envoyer un message
PUT  /:gameId/messages/read         Marquer comme lus
```

### Participations — `/api/participations`
```
GET    /my           Mes demandes de participation
PUT    /:id/accept   Accepter une demande (créateur uniquement)
PUT    /:id/reject   Refuser une demande (créateur uniquement)
PATCH  /:id/cancel   Annuler ma participation
```

### Messages — `/api/messages`
```
GET    /conversations   Toutes mes conversations
DELETE /:id             Supprimer un message
```

### Notifications — `/api/notifications`
```
GET  /               Mes notifications
GET  /unread-count   Nombre de non-lues
PUT  /read-all       Tout marquer comme lu
PUT  /:id/read       Marquer une notification comme lue
DELETE /:id          Supprimer une notification
```

---

## Installation

### Prérequis

- Flutter SDK 3.2+
- Node.js 18+
- Docker & Docker Compose
- Clés API : Mapbox, Firebase (FCM), Google Maps (optionnel)

### Backend

```bash
cd backend
cp .env.example .env       # Remplir les variables d'environnement
npm install
docker-compose up -d       # Démarre PostgreSQL sur le port 5433
npx prisma migrate dev     # Applique les migrations
npm run prisma:seed        # (optionnel) Données de test
npm run dev                # Démarre l'API sur le port 3000
```

### Mobile

```bash
cd app
flutter pub get
flutter run
```

> Pour la carte, renseigner le token Mapbox dans `lib/main.dart`.

---

## Variables d'environnement

Fichier `backend/.env` :

```env
# Base de données
DATABASE_URL=postgresql://tcg_user:tcg_password@127.0.0.1:5433/tcg_matchmaking

# JWT
JWT_SECRET=your-secret-key
ACCESS_TOKEN_EXPIRY=15m
JWT_REFRESH_SECRET=your-refresh-secret
REFRESH_TOKEN_EXPIRY=7d

# Firebase (notifications push)
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=

# OAuth (optionnel)
FACEBOOK_APP_ID=
FACEBOOK_APP_SECRET=
INSTAGRAM_CLIENT_ID=
INSTAGRAM_CLIENT_SECRET=

# Serveur
PORT=3000
NODE_ENV=development
```

---

## Scripts utilitaires

```bash
# Prisma
npm run prisma:generate     # Génère le client Prisma
npm run prisma:migrate      # Applique les migrations
npm run prisma:studio       # Interface visuelle de la BDD

# Données
npm run prisma:seed         # Insère des données de test
npm run npc:seed            # Crée les comptes NPC (bots)
npm run npc:cron            # Lance les tâches quotidiennes (cron)
npm run npc:cleanup         # Nettoie les données expirées
```

---

## Sécurité & anti-spam

| Protection | Limite |
|-----------|--------|
| Rate limiter global | 100 req/min par IP |
| Auth (login/register) | 10 tentatives / 15 min |
| Création de partie | 1 partie non remplie / jour / utilisateur |
| Demandes de participation | 20 / heure |
| Tokens JWT | Access : 15 min — Refresh : 7 jours |

---

## Comptes de test

```
romain@duelfinder.com / password123   → Romain-TCG
dev@duelfinder.com    / password123   → Dev1234
```

---

## Déploiement

Le backend est hébergé sur **Railway** avec une base PostgreSQL managée.

```
API : https://duelfinder-production.up.railway.app/api
```

Pour déployer une nouvelle version :
```bash
git push origin main   # Railway déploie automatiquement depuis main
```
