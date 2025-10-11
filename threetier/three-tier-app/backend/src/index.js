import express from 'express';
import cors from 'cors';
import { pool, query } from './db.js';
import { router } from './routes.js';
import { liveness, readiness } from './health.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const app = express();
const PORT = process.env.API_PORT || 4000;
const CORS_ORIGIN = process.env.CORS_ORIGIN || '*';

app.use(cors({ origin: CORS_ORIGIN, credentials: false }));
app.use(express.json());

// Health endpoints
app.get('/healthz', liveness);
app.get('/readyz', readiness);

// API routes
app.use('/api', router);

// Migration runner (idempotent)
async function migrate() {
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const file = path.join(__dirname, '..', 'migrations', '001_init.sql');
  const sql = fs.readFileSync(file, 'utf-8');
  console.log('[migrate] applying 001_init.sql');
  await pool.query(sql);
  console.log('[migrate] done');
}

if (process.argv[2] === 'migrate') {
  migrate()
    .then(() => process.exit(0))
    .catch(err => {
      console.error('[migrate] failed', err);
      process.exit(1);
    });
} else {
  app.listen(PORT, () => {
    console.log(`[api] listening on :${PORT}`);
  });
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('[api] SIGTERM received, closing pool...');
  await pool.end();
  process.exit(0);
});