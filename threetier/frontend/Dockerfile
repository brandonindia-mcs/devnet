# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Serve static with a tiny web server (vite preview or nginx). Using vite preview for simplicity.
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/dist ./dist
# vite preview serves static dist
EXPOSE 5173
CMD ["sh", "-c", "npx vite preview --host --port 5173"]