import React, { useEffect, useState } from 'react';
import { listItems, addItem, deleteItem } from './api.js';

export default function App() {
  const [items, setItems] = useState([]);
  const [title, setTitle] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  async function refresh() {
    try {
      setLoading(true);
      setError('');
      const data = await listItems();
      setItems(data);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { refresh(); }, []);

  async function handleAdd(e) {
    e.preventDefault();
    if (!title.trim()) return;
    try {
      const newItem = await addItem(title.trim());
      setItems(prev => [newItem, ...prev]);
      setTitle('');
    } catch (e) {
      setError(e.message);
    }
  }

  async function handleDelete(id) {
    try {
      await deleteItem(id);
      setItems(prev => prev.filter(i => i.id !== id));
    } catch (e) {
      setError(e.message);
    }
  }

  return (
    <div style={{ maxWidth: 640, margin: '3rem auto', fontFamily: 'system-ui, sans-serif' }}>
      <h1>Three-tier App</h1>
      <p>A minimal React + Node.js + Postgres stack.</p>

      <form onSubmit={handleAdd} style={{ marginBottom: '1rem' }}>
        <input
          value={title}
          onChange={e => setTitle(e.target.value)}
          placeholder="New item title"
          style={{ padding: '0.5rem', width: '70%' }}
        />
        <button type="submit" style={{ padding: '0.55rem 1rem', marginLeft: '0.5rem' }}>
          Add
        </button>
      </form>

      {error && <div style={{ color: 'crimson', marginBottom: '1rem' }}>Error: {error}</div>}
      {loading ? (
        <div>Loading…</div>
      ) : items.length === 0 ? (
        <div>No items yet.</div>
      ) : (
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {items.map(item => (
            <li key={item.id} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.5rem 0', borderBottom: '1px solid #eee' }}>
              <span>
                <strong>{item.title}</strong>
                <small style={{ marginLeft: 8, color: '#666' }}>
                  {new Date(item.created_at).toLocaleString()}
                </small>
              </span>
              <button onClick={() => handleDelete(item.id)} style={{ color: 'crimson' }}>
                Delete
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}