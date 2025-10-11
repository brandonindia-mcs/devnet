const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:4000/api';

export async function listItems() {
  const r = await fetch(`${API_BASE}/items`);
  if (!r.ok) throw new Error('Failed to fetch items');
  return r.json();
}

export async function addItem(title) {
  const r = await fetch(`${API_BASE}/items`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title })
  });
  if (!r.ok) {
    const err = await r.json().catch(() => ({}));
    throw new Error(err.error || 'Failed to add item');
  }
  return r.json();
}

export async function deleteItem(id) {
  const r = await fetch(`${API_BASE}/items/${id}`, { method: 'DELETE' });
  if (!r.ok && r.status !== 204) throw new Error('Failed to delete item');
}