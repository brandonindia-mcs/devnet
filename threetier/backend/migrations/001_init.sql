CREATE TABLE IF NOT EXISTS items (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL CHECK (char_length(title) <= 255),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Seed once if empty
INSERT INTO items (title)
SELECT 'Welcome to the three-tier app'
WHERE NOT EXISTS (SELECT 1 FROM items);