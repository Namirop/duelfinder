# TCG Matchmaking Backend

Backend API pour l'application mobile de mise en relation de joueurs de TCG (Trading Card Games).

## Stack technique

- **Node.js** + **Express** - Serveur HTTP
- **Prisma** - ORM (PostgreSQL)
- **Firebase Admin SDK** - Notifications push (FCM)
- **JWT** - Authentification

## Structure du projet

```
backend/
├── prisma/
│   └── schema.prisma       # Modèles de données
├── src/
│   ├── config/             # Configuration (Firebase, DB, JWT)
│   ├── controllers/        # Logique des routes
│   ├── middlewares/        # Auth JWT, validation
│   ├── routes/             # Définition des endpoints
│   ├── services/           # Logique métier
│   ├── app.js              # Configuration Express
│   └── server.js           # Point d'entrée
├── .env.example
├── package.json
└── README.md
```

## Installation

```bash
# Installer les dépendances
npm install

# Copier et configurer les variables d'environnement
cp .env.example .env

# Générer le client Prisma
npm run prisma:generate

# Créer/migrer la base de données
npm run prisma:migrate
```

## Développement

```bash
# Lancer en mode développement (avec hot reload)
npm run dev

# Lancer Prisma Studio (interface graphique DB)
npm run prisma:studio
```

## Endpoints API

| Module          | Base URL               |
|-----------------|------------------------|
| Auth            | `/api/auth`            |
| Users           | `/api/users`           |
| Games           | `/api/games`           |
| Participations  | `/api/participations`  |
| Messages        | `/api/messages`        |
| Notifications   | `/api/notifications`   |

## Configuration requise

Voir `.env.example` pour la liste complète des variables d'environnement :
- `DATABASE_URL` - URL PostgreSQL
- `JWT_SECRET` - Clé secrète JWT
- Firebase Admin SDK credentials
- OAuth Facebook/Instagram (optionnel)
