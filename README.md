# DuelFinder

Application mobile de mise en relation de joueurs de TCG (Trading Card Games). Trouvez des joueurs près de chez vous et organisez des parties.

## Jeux supportés

- Pokémon TCG
- Yu-Gi-Oh!
- One Piece Card Game
- Naruto TCG

## Stack technique

### Mobile (Flutter)
- **Framework** : Flutter 3.2+
- **State Management** : Riverpod
- **Navigation** : GoRouter
- **Maps** : Google Maps / Mapbox
- **Notifications** : Firebase Cloud Messaging

### Backend (Node.js)
- **Runtime** : Node.js (ES Modules)
- **Framework** : Express.js
- **ORM** : Prisma
- **Base de données** : PostgreSQL
- **Auth** : JWT + bcrypt

## Installation

### Prérequis
- Flutter SDK 3.2+
- Node.js 18+
- Docker & Docker Compose
- Clés API : Google Maps, Mapbox, Firebase

### Backend

```bash
cd backend
cp .env.example .env   # Configurer les variables d'environnement
npm install
docker-compose up -d   # Lance PostgreSQL
npx prisma migrate dev
npm run dev
```

### Mobile

```bash
cd app
flutter pub get
flutter run
```

## Structure du projet

```
├── app/                    # Application Flutter
│   └── lib/
│       ├── core/           # Config, theme, constantes
│       ├── features/       # Modules fonctionnels
│       │   ├── auth/       # Authentification
│       │   ├── games/      # Gestion des parties
│       │   ├── home/       # Carte et recherche
│       │   ├── messages/   # Chat
│       │   └── profile/    # Profil utilisateur
│       └── shared/         # Widgets partagés
│
└── backend/                # API Node.js
    ├── src/
    │   ├── controllers/    # Handlers des routes
    │   ├── services/       # Logique métier
    │   ├── routes/         # Définition des routes
    │   └── middlewares/    # Auth, validation
    └── prisma/             # Schéma et migrations
```

## Fonctionnalités

- Création et recherche de parties par géolocalisation
- Système de demande de participation
- Chat en temps réel par partie
- Notifications push
- Authentification (email/password, réseaux sociaux)
