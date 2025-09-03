# INSTAL DEPENDENCIES AND CREATE A VERY BASIC DOCKER LOCAL CLUSTER

### k8s
# LATEST STABLE
version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

version=1.33.4
curl -LO "https://dl.k8s.io/release/v${version}/bin/darwin/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/v${version}/bin/darwin/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | shasum -a 256 --check
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo chown root: /usr/local/bin/kubectl

kubectl version
kubectl version --client
kubectl version --client --output=yaml
alias k=kubectl

### HELM via BREW 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew --version
brew install kubernetes-helm
helm version

### KIND via BREW
brew install kind
kind version
kind help
>> kind creates and manages local Kubernetes clusters using Docker container 'nodes'

### LOCAL CONTAINER REGISTRY
# MACOS CONTROL CENTER RUNS ON PORT 5000
docker run -d -p 5001:5000 --name registry registry:2

### REDIS CLUSTER
# ADD STABLE REPO AND DEPLOY CHARTS:
helm repo add bitnami https://charts.bitnami.com/bitnami
ls ~/.cache/helm/repository/
# helm repo rm bitnami
helm install my-redis bitnami/redis

helm env

project_name=k8s-level-0
mkdir -p ./$project_name
### KUBERNETES ON DEPLOYMENT DOCKER
deployment=nginx-deployment
echo|cat >./$project_name/$deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
EOF
k apply -f ./$project_name/$deployment.yaml
k expose deployment $deployment --port=80 --type=LoadBalancer
k get pods,svc

# CREATE A 3-NODE CLUSTER
cluster=cluster-config
echo|cat >./$project_name/$cluster.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF
kind create cluster --config ./$project_name/$cluster.yaml

# CLEAN UP
k get deployment
k get svc
k get pods
helm list

k delete deployment nginx-deployment
k delete svc nginx-deployment
k delete svc my-redis-replicas
k delete svc my-redis-headless
k delete svc my-redis-master
k delete pods --all
