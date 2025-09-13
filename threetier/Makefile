.PHONY: up down logs ps migrate seed reset

up:
\tdocker compose up -d --build

down:
\tdocker compose down

logs:
\tdocker compose logs -f --tail=200

ps:
\tdocker compose ps

migrate:
\tdocker compose run --rm api node src/index.js migrate

reset:
\tdocker compose down -v
\tdocker compose up -d --build