import express from 'express';
import { query } from './db.js';

export const router = express.Router();

// List items
router.get('/items', async (req, res) => {
  try {
    const { rows } = await query(
      'SELECT id, title, created_at FROM items ORDER BY created_at DESC'
    );
    res.json(rows);
  } catch (err) {
    console.error('[api] GET /items', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Create item
router.post('/items', async (req, res) => {
  const { title } = req.body || {};
  if (!title || typeof title !== 'string' || !title.trim()) {
    return res.status(400).json({ error: 'Invalid title' });
  }
  try {
    const { rows } = await query(
      'INSERT INTO items (title) VALUES ($1) RETURNING id, title, created_at',
      [title.trim()]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error('[api] POST /items', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Delete item
router.delete('/items/:id', async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) return res.status(400).json({ error: 'Invalid id' });
  try {
    const { rowCount } = await query('DELETE FROM items WHERE id = $1', [id]);
    if (rowCount === 0) return res.status(404).json({ error: 'Not found' });
    res.status(204).send();
  } catch (err) {
    console.error('[api] DELETE /items/:id', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});