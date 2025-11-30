
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

brew install kubernetes-cli@${major_version}
