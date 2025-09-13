#!/usr/local/bin/bash
. ./k.config.sh
# set -e

which kubectl
ls $(which kubectl)
$(which kubectl) version
_namespace=lab02d
_project=k8s-lab-02
_cluster=lab-cluster
mkdir -p ./$_project
kube_context
localhostname=nginx.local

# CREATE OR REUSE CLUSTER
kubernetes_version=$(kubectl version|grep -i 'client version'|awk '{print $3}')\
  && echo "k8s version $kubernetes_version"
(
kubectl config use-context ${kind}$_cluster >/dev/null 2&>1\
  || . ./k8s-lab-00/lab00.sh $_cluster
)
kubectl get namespace $_namespace\
  || kubectl create namespace $_namespace\
  && kubectl config set-context --current --namespace=$_namespace
kube_context

### KUBERNETES ON DEPLOYMENT DOCKER
label=nginx
echo|cat >./$_project/$_namespace-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2 # You can adjust the number of replicas
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
        image: nginx:latest
        ports:
        - containerPort: 80
EOF
echo|cat >./$_project/$_namespace-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80 # The port the service will listen on
      targetPort: 80 # The port the NGINX container listens on
      nodePort: 30080 # Optional: Specify a port in the 30000-32767 range. If omitted, Kubernetes assigns one.

EOF

:
kubectl apply --namespace=$_namespace -f ./$_project/$_namespace-deployment.yaml
kubectl apply --namespace=$_namespace -f ./$_project/$_namespace-service.yaml
kubectl get deployment,ingress,svc,pods
echo -e "\n⏳ Waiting for ingress controller pod ($label) to be ready..."

kubectl wait --namespace $_namespace \
  --for=condition=Ready pod \
  -l app=$label \
  --timeout=120s

kubectl get deployments
kubectl get services
kubectl get pods -o wide

# echo "127.0.0.1 $localhostname" | sudo tee -a /etc/hosts
echo "$_project script finished - run: echo \"127.0.0.1 $localhostname\" | sudo tee -a /etc/hosts"

