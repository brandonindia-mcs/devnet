const jwt = require('jsonwebtoken');
const token = jwt.sign({ sub: 1 }, 'mh9k3Y8+JqD7rCnf0XeyU4tQz5VhmAd0YlBp7Km5Z2s=', { expiresIn: '1h' });
console.log(token);

echo -n "YourP@ssw0rd!" | base64
echo -n "dbadmin@twotierpgserver" | base64
echo -n "twotierpgserver.postgres.database.azure.com" | base64
echo -n "mh9k3Y8+JqD7rCnf0XeyU4tQz5VhmAd0YlBp7Km5Z2s=" | base64
