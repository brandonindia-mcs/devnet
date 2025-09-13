const express = require('express');
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json());

app.use((req, res, next) => {
  const token = (req.headers.authorization || '').replace('Bearer ', '');
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.sendStatus(403);
  }
});

app.get('/api/transactions', (req, res) => {
  res.json([
    { id: 1, amount: 100, userId: req.user.sub },
    { id: 2, amount: 250, userId: req.user.sub }
  ]);
});

app.listen(4000, () => console.log('Transaction service running on port 4000'));
