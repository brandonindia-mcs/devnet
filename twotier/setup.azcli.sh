### ⚙️ Azure Setup
az group create --name twotierrg --location eastus2

az acr create --resource-group twotierrg --name twotieracr --sku Standard

az aks create \
  --resource-group twotierrg \
  --name twotieraks \
  --node-count 2 \
  --enable-managed-identity \
  --attach-acr twotieracr \
  --generate-ssh-keys

az aks get-credentials --resource-group twotierrg --name twotieraks

### 🐘 PostgreSQL Flexible Server v17 Setup
az postgres flexible-server create \
  --resource-group twotierrg \
  --name twotierpgserver \
  --admin-user dbadmin \
  --admin-password YourP@ssw0rd! \
  --sku-name Standard_B1ms \
  --version 17 \
  --location eastus \
  --public-access all

az postgres flexible-server db create \
  --resource-group twotierrg \
  --server-name twotierpgserver \
  --database-name authdb

# POSTGRES CLIENT
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL
);

INSERT INTO users (username, password_hash)
VALUES (
  'brandon',
  crypt('Brandon1', gen_salt('bf'))
);

### 🔐 JWT + Base64 Utilities
# Generate JWT Token (Node.js)
const jwt = require('jsonwebtoken');
const token = jwt.sign({ sub: 1 }, 'mh9k3Y8+JqD7rCnf0XeyU4tQz5VhmAd0YlBp7Km5Z2s=', { expiresIn: '1h' });
console.log(token);
# Base64 Encoding
echo -n "YourP@ssw0rd!" | base64
echo -n "dbadmin@twotierpgserver" | base64
echo -n "twotierpgserver.postgres.database.azure.com" | base64
echo -n "mh9k3Y8+JqD7rCnf0XeyU4tQz5VhmAd0YlBp7Km5Z2s=" | base64
