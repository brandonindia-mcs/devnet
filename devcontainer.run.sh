docker run -d -it --privileged \
 -v ~/devnet:/home/developer/devnet \
 -v ~/devnet/database:/home/developer/database \
 -v ~/devnet/appdev-twotier:/home/developer/appdev \
 -w /home/developer/appdev \
 \
 -v /var/run/docker.sock:/var/run/docker.sock \
 \
 -v ~/.ssh:/home/developer/.ssh \
 -e gitname="$GITNAME" -e gituser="$GITUSER" -e gitkey="$GITKEY" \
 --network=appdev \
 \
 --name appdev-twotier \
 -v appdev-k8s.vscode-server:/home/developer/.vscode-server \
 user:k8s


docker run -it --privileged \
 -v ~/devnet:/home/developer/devnet \
 -v ~/devnet/database:/home/developer/database \
 -v ~/devnet/appdev-twotier:/home/developer/appdev \
 -w /home/developer/appdev \
 \
 -v ~/.ssh:/home/developer/.ssh \
 -e gitname="$GITNAME" -e gituser="$GITUSER" -e gitkey="$GITKEY" \
 --network=appdev \
 \
 --rm \
 \
 -v /var/run/docker.sock:/var/run/docker.sock \
 \
 user:k8s

HOST_SOCK=~/.docker/run/docker.sock
SOCK_GID=$(stat -f '%g' "$HOST_SOCK")
 -v $(which docker):/usr/bin/docker \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v $HOME/.docker/run/docker.sock:/var/run/docker.sock \
 --group-add $SOCK_GID \
   -u 1000:1000 \
  --group-add=$SOCK_GID \

  sudo chmod +a "user:$(id -un) allow read,write" ~/.docker/run/docker.sock
  sudo chmod +a "user:$(id -un) allow read,write" /var/run/docker.sock
  
