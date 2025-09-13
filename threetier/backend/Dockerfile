FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY src ./src
COPY migrations ./migrations
COPY scripts/wait-for.sh ./scripts/wait-for.sh
RUN chmod +x ./scripts/wait-for.sh
ENV NODE_ENV=production
EXPOSE 4000
CMD ["sh", "-c", "./scripts/wait-for.sh node src/index.js"]