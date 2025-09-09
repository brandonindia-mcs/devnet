#!/bin/bash
. ./k.config.sh

export _namespace=lab00
export _cluster=lab-cluster
export _nginx=nginx-deployment
export _project=k8s-lab-00
mkdir -p ./$_project

kg namespace $_namespace >/dev/null 2>&1 || kc namespace $_namespace
kcfg set-context --current --namespace=$_namespace

### KUBERNETES ON DEPLOYMENT DOCKER
echo|cat >./$_project/$_nginx.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $_nginx
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
        resources:
          requests:
            cpu: "100m"      # ~0.1 core
            memory: "128Mi"  # 128 MB
          limits:
            cpu: "250m"      # ~0.25 core
            memory: "256Mi"  # 256 MB
EOF
k apply -f ./$_project/$_nginx.yaml
k expose deployment $_nginx --port=80 --type=LoadBalancer
k get pods,svc

# CREATE A 3-NODE CLUSTER
echo|cat >./$_project/$_cluster-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF
kind create cluster -n $_cluster --config ./$_project/$_cluster-config.yaml

# RENAME DEFAULT
k config rename-context kind-kind kind-lab-cluster

# CLEAN UP
k get deployment
k get svc
k get pods
helm list



k delete deployment $_nginx
k delete svc $_nginx
k delete pods --all



### REDIS CLUSTER
# ADD STABLE REPO AND DEPLOY CHARTS:
helm repo add bitnami https://charts.bitnami.com/bitnami
ls ~/.cache/helm/repository/
# helm repo rm bitnami
helm install $_project-redis bitnami/redis
helm env

k delete deployment $_project-redis
k delete svc $_project-redis-replicas
k delete svc $_project-redis-headless
k delete svc $_project-redis-master



### LOCAL CONTAINER REGISTRY
# MACOS CONTROL CENTER RUNS ON PORT 5000
docker run -d -p 5001:5000 --name registry registry:2
docker rm -f registry
