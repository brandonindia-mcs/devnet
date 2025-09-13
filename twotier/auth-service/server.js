const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME || 'authdb',
  port: 5432,
  ssl: { rejectUnauthorized: false }
});

app.post('/auth/register', async (req, res) => {
  const { username, password } = req.body;
  const hash = await bcrypt.hash(password, 10);
  try {
    await pool.query(
      'INSERT INTO users (username, password_hash) VALUES ($1, $2)',
      [username, hash]
    );
    res.sendStatus(201);
  } catch (err) {
    res.status(400).json({ error: 'User already exists or invalid input' });
  }
});

app.post('/auth/login', async (req, res) => {
  const { username, password } = req.body;
  const { rows } = await pool.query(
    'SELECT id, password_hash FROM users WHERE username = $1',
    [username]
  );
  if (!rows.length || !(await bcrypt.compare(password, rows[0].password_hash))) {
    return res.sendStatus(401);
  }
  const token = jwt.sign({ sub: rows[0].id }, process.env.JWT_SECRET, {
    expiresIn: '1h'
  });
  res.json({ token });
});

app.listen(3000, () => console.log('Auth service running on port 3000'));
