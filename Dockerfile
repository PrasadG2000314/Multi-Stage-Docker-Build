
# Stage 1: Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Dependency files පමණක් මුලින් copy කර install කිරීම (Docker cache optimization)
COPY package*.json ./
RUN npm ci

# Source code copy කර build කිරීම
COPY . .
RUN npm run build || true # TypeScript compile script එක (dist folder එක සාදයි)

# Stage 2: Production runtime stage
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Security best practice: root නොවන user කෙනෙක් යොදා ගැනීම
USER node

# Builder stage එකෙන් අවශ්‍ය files පමණක් copy කර ගැනීම
COPY --chown=node:node package*.json ./
RUN npm ci --only=production

COPY --chown=node:node --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/index.js"]
