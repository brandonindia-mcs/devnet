docker run -d -it \
 -v ~/devnet:/home/developer/devnet \
 -v ~/devnet/database:/home/developer/database \
 -v ~/devnet/appdev-twotier:/home/developer/appdev \
 -w /home/developer/appdev \
 \
 -e gitname="$GITNAME" -e gituser="$GITUSER" -e gitkey="$GITKEY" \
 --network=appdev \
 \
 --name appdev-twotier \
 --rm \
 -v appdev-k8s.vscode-server:/home/developer/.vscode-server \
 -v ~/.ssh:/home/developer/.ssh \
 user:k8s
