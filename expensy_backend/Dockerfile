# --- Étape 1 : Build (Compilation TypeScript -> JavaScript) ---
FROM node:20-alpine AS builder

WORKDIR /app

# Copie des définitions de dépendances
COPY package*.json ./

# Installation de TOUTES les dépendances (y compris devDependencies pour TypeScript)
RUN npm ci

# Copie de la configuration TS et du code source
COPY tsconfig.json ./
COPY src ./src

# Compilation TypeScript -> génère le dossier dist/
RUN npm run build

# --- Étape 2 : Production (Image finale ultra-légère) ---
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Création d'un utilisateur non-root pour la sécurité
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nodejsuser

COPY package*.json ./

# Installation UNIQUEMENT des dépendances de production (sans devDependencies)
RUN npm ci --omit=dev

# Copie du code JavaScript compilé depuis l'étape builder
COPY --from=builder /app/dist ./dist

# Modification des permissions
USER nodejsuser

# Port par défaut d'Express (ajustez si votre code écoute sur un autre port, ex: 5000, 8000)
EXPOSE 5000

# Commande directe de démarrage en production
CMD ["node", "dist/server.js"]