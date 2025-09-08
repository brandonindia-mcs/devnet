### INSTAL DEPENDENCIES AND CREATE A VERY BASIC DOCKER LOCAL CLUSTER
# k8s
# LATEST STABLE
version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

# TARGET VERSION
version=1.32.2
curl -LO "https://dl.k8s.io/release/v${version}/bin/darwin/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/v${version}/bin/darwin/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | shasum -a 256 --check
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo chown root: /usr/local/bin/kubectl

alias k=kubectl
k version
k version --client
k version --client --output=yaml

brew --version
### HELM via BREW 
brew uninstall kubernetes-helm
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install kubernetes-helm
helm version

### KIND via BREW
brew uninstall kind
brew install kind
kind version
kind help
echo ">>> kind creates and manages local Kubernetes clusters using Docker container 'nodes' <<<"

