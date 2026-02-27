# DuelFinder - Contexte Projet

## Description
Application mobile de mise en relation de joueurs de TCG (Trading Card Games). Les utilisateurs peuvent créer des parties, trouver des joueurs à proximité, et organiser des rencontres pour jouer en physique.

## Stack Technique

### Frontend Mobile (`/app`)
- **Flutter** (Dart) - SDK 3.2+
- **Riverpod** - State management
- **GoRouter** - Navigation
- **Google Maps / Mapbox** - Cartographie
- **Firebase Messaging** - Notifications push
- **Dio** - Client HTTP

### Backend (`/backend`)
- **Node.js** avec ES Modules
- **Express.js** - Framework API
- **Prisma** - ORM
- **PostgreSQL** - Base de données (Docker)
- **JWT + bcrypt** - Authentification
- **Firebase Admin** - Notifications push

## Jeux TCG Supportés
- Pokémon TCG
- Yu-Gi-Oh!
- One Piece Card Game
- Naruto TCG

Les jeux sont définis comme enum dans :
- Backend : `backend/prisma/schema.prisma` → `enum GameType`
- Frontend : `app/lib/features/games/entities/game.dart` → `enum GameType`

## Architecture Frontend

```
app/lib/
├── core/           # DI, theme, constantes, enums
├── features/       # Modules par fonctionnalité
│   ├── auth/       # Login, register, OAuth
│   ├── games/      # Création/gestion de parties
│   ├── home/       # Map, recherche, cards
│   ├── messages/   # Chat par partie
│   ├── participations/
│   ├── profile/
│   └── notifications/
└── shared/         # Widgets réutilisables
```

Chaque feature suit la structure : `entities/`, `models/`, `providers/`, `screens/`, `widgets/`

## Architecture Backend

```
backend/src/
├── controllers/    # Handlers des routes
├── services/       # Logique métier
├── routes/         # Définition des endpoints
├── middlewares/    # Auth, validation, error handling
└── config/         # Firebase, etc.
```

## Base de données (Prisma)

Modèles principaux :
- **User** - Utilisateurs (email, password, OAuth)
- **Game** - Parties (type, lieu, date, créateur)
- **Participation** - Demandes de participation (PENDING/ACCEPTED/REJECTED)
- **Message** - Chat par partie
- **Notification** - Push notifications

## Commandes Utiles

```bash
# Backend
cd backend
docker-compose up -d          # Lance PostgreSQL
npm run dev                   # Lance le serveur
npx prisma migrate dev        # Migrations
npx prisma studio             # GUI base de données

# Frontend
cd app
flutter pub get
flutter run
flutter pub run build_runner build  # Génère .g.dart / .freezed.dart
```

## Variables d'environnement

Backend (`backend/.env`) :
- `DATABASE_URL` - URL PostgreSQL
- `JWT_SECRET` - Secret pour les tokens
- `FIREBASE_*` - Config Firebase

## Notes de développement

- L'UI utilise `GameType.values` donc tout nouveau jeu ajouté à l'enum apparaît automatiquement
- Les parties sont géolocalisées avec lat/lng
- Le statut des parties : OPEN → FULL → IN_PROGRESS → COMPLETED/CANCELLED
- Fichiers générés (.g.dart, .freezed.dart) sont dans le .gitignore
