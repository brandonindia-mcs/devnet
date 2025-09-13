#!/usr/local/bin/bash
. ./k.config.sh
# set -e

which kubectl
ls $(which kubectl)
$(which kubectl) version
_namespace=lab02c
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
  name: $_namespace-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $label
  template:
    metadata:
      labels:
        app: $label
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "250m"
            memory: "256Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: $_namespace-service
spec:
  type: NodePort
  selector:
    app: $label
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF
echo|cat >./$_project/$_namespace-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: $localhostname
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $_namespace-service
            port:
              number: 80
EOF

:
kubectl apply --namespace=$_namespace -f ./$_project/$_namespace-deployment.yaml
kubectl apply --namespace=$_namespace -f ./$_project/$_namespace-ingress.yaml
kubectl get deployment,ingress,svc,pods
echo -e "\n⏳ Waiting for ingress controller pod ($label) to be ready..."

kubectl wait --namespace $_namespace \
  --for=condition=Ready pod \
  -l app=$label \
  --timeout=120s

kubectl get deployment,ingress,svc,pods

# echo "127.0.0.1 $localhostname" | sudo tee -a /etc/hosts
echo "$_project script finished - run: echo \"127.0.0.1 $localhostname\" | sudo tee -a /etc/hosts"

