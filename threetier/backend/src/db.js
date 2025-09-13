import pkg from 'pg';
const { Pool } = pkg;

const required = ['DATABASE_URL'];
required.forEach(k => {
  if (!process.env[k]) {
    console.error(`[config] Missing env ${k}`);
    process.exit(1);
  }
});

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000
});

export async function query(text, params) {
  const start = Date.now();
  const res = await pool.query(text, params);
  const duration = Date.now() - start;
  console.log(`[db] ${text.split('\n')[0]} (${duration}ms)`);
  return res;
}