# docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' appdev-twotier
export DOCKER_IP_ADDRESS=$(hostname -I)
echo docker ip: $DOCKER_IP_ADDRESS
