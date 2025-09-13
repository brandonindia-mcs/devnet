#!/usr/local/bin/bash
. ./k.config.sh
nginx_release="ingress-nginx"
helm_chart="ingress-nginx/ingress-nginx"

nginx_service=$_namespace-nginx-service
nginx_deployment=$_namespace-nginx-deployment

helm repo add $nginx_release https://kubernetes.github.io/ingress-nginx
helm repo update


### REDIS
redis_namespace=redis-lab
kubectl create namespace $redis_namespace\
  || kubectl config set-context --current --namespace=$redis_namespace
kube_context
# ADD STABLE REPO AND DEPLOY CHARTS:
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install redis-cluster bitnami/redis-cluster \
  --namespace $redis_namespace \
  --set cluster.enabled=true \
  --set replica.replicaCount=1 \
  --set usePassword=false \
  --set persistence.enabled=false

helm install $_project-redis bitnami/redis

helm env

kubectl get pods -n $redis_namespace
# VERIFY REDIS DEPLOYMENT
kubectl exec -it redis-cluster-0 -n $redis_namespace -- redis-cli -c cluster nodes

:
kubectl get svc,pods,deployment
helm list
:
kubectl delete deployment $_project-redis
kubectl delete svc $_project-redis-replicas
kubectl delete svc $_project-redis-headless
kubectl delete svc $_project-redis-master


kubectl get svc,pods,deployment
helm list
:
# CLEAN UP
kind delete cluster -n $_cluster
kubectl delete deployment $_nginx
kubectl delete svc $_nginx
kubectl delete pods --all


## LOCAL CONTAINER REGISTRY
MACOS CONTROL CENTER RUNS ON PORT 5000
docker run -d -p 5001:5000 --name registry registry:2
docker rm -f registry

kubectl config use-kube_context docker-desktop\
  && kubectl config set-context --current --namespace default
echo $_project script finished
