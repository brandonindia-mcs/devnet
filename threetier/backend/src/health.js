import { pool } from './db.js';

export async function liveness(req, res) {
  res.status(200).json({ status: 'ok' });
}

export async function readiness(req, res) {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'ready' });
  } catch (err) {
    res.status(503).json({ status: 'not-ready', error: err.message });
  }
}