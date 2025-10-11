cp .env .env.local 2>/dev/null || true
cd ./backend && npm install && cd ..
cd ./frontend && npm install && cd ..
docker compose up -d --build
