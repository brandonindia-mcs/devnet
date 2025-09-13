#!/bin/bash

# Create env.json from injected secrets
cat <<EOF > /usr/share/nginx/html/env.json
{
  "featureFlag": "${FEATURE_FLAG}",
  "apiBaseUrl": "${API_BASE_URL}",
  "jwtSecret": "${JWT_SECRET}"
}
EOF

# Start NGINX
nginx -g "daemon off;"
