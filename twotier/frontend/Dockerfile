FROM nginx:alpine

# Install minimal shell utilities
RUN apk add --no-cache bash

# Copy static HTML
COPY index.html /usr/share/nginx/html/index.html

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start NGINX via entrypoint
ENTRYPOINT ["/entrypoint.sh"]
