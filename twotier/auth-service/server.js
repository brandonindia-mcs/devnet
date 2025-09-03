const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST,           // e.g. twoTierPgServer.postgres.database.azure.com
  user: process.env.DB_USER,           // dbadmin@twoTierPgServer
  password: process.env.DB_PASS,
  database: 'authdb',
  port: 5432,
  ssl: false                           // set to true if you enforce SSL
});

app.post('/register', async (req, res) => {
  const { username, password } = req.body;
  const hash = await bcrypt.hash(password, 10);
  await pool.query(
    'INSERT INTO users (username, password_hash) VALUES ($1, $2)',
    [username, hash]
  );
  res.sendStatus(201);
});

app.post('/login', async (req, res) => {
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

app.listen(3000, () => console.log('Auth service running on 3000'));
