#!/usr/bin/env sh
# Minimal wait-for dependency using psql
set -e

if [ -z "$DATABASE_URL" ]; then
  echo "DATABASE_URL not set"
  exit 1
fi

echo "Waiting for database..."
for i in $(seq 1 60); do
  if PGPASSWORD="${POSTGRES_PASSWORD}" psql "$DATABASE_URL" -c "SELECT 1" >/dev/null 2>&1; then
    echo "Database is up"
    exec "$@"
  fi
  echo "Retry $i/60..."
  sleep 2
done

echo "Database did not become ready in time"
exit 1