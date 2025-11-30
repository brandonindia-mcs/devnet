### INSTAL DEPENDENCIES AND CREATE A VERY BASIC DOCKER LOCAL CLUSTER
# k8s
# LATEST STABLE
# version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

# TARGET VERSION
version=1.32.5
# version=1.34.1
curl -LO "https://dl.k8s.io/release/v${version}/bin/darwin/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/v${version}/bin/darwin/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | shasum -a 256 --check
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo chown root: /usr/local/bin/kubectl
