#!/usr/local/bin/bash
export _project=k8s-lab-01

lab_cluster=lab-cluster
default_cluster=docker-desktop
export _cluster=$default_cluster && unset kind
export _namespace=lab01

localhostname=nginx.local

nginx_release="ingress-nginx"
helm_chart="ingress-nginx/ingress-nginx"

nginx_service=lab01-nginx-service
nginx_deployment=lab01-nginx-deployment
mkdir -p ./$_project
_varlist_=()
_varlist_+=($_project)
_varlist_+=($_cluster)
_varlist_+=($_namespace)
_varlist_+=($localhostname)
_varlist_+=($nginx_release)
_varlist_+=($helm_chart)
_varlist_+=($nginx_service)
_varlist_+=($nginx_deployment)
kubectl config use-context ${kind}${_cluster}
:
helm repo add $nginx_release https://kubernetes.github.io/ingress-nginx
helm repo update

# kubectl get namespace $_namespace >/dev/null 2>&1 || kubectl create namespace $_namespace
# kubectl config set-context --current --namespace=$_namespace

# CREATE OR REUSE CLUSTER
kubernetes_version=$(kubectl version|grep -i 'client version'|awk '{print $3}')\
  && echo "k8s version $kubernetes_version"\
  && kubectl config use-context ${kind}${_cluster} 2>/dev/null\
  || kind create cluster -n $_cluster --config ../k8s-lab-00/$_cluster-config.yaml
context
:
kubectl get namespace $_namespace\
  || kubectl create namespace $_namespace\
  && kubectl config set-context --current --namespace=$_namespace
context
kubectl get all --namespace $_namespace

# ERROR | 000 ) 404
echo nginx http status code:$(curl -s -o /dev/null -w "%{http_code}" 127.0.0.1)

:
# INSTALL THE INGRESS-NGINX CONTROLLER
helm install $nginx_release $helm_chart \
  --namespace $_namespace \
  --set controller.publishService.enabled=true
echo -e "\n⏳ Waiting for ingress controller pod to be ready..."
kubectl wait --namespace $_namespace \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/name=$nginx_release \
  --timeout=120s
echo -ne "\nhelm list --all-namespaces:\n$(helm list --all-namespaces)\n"
echo -ne "\nkubectl config view --minify:\n$(kubectl config view --minify)\n"

# 404
echo nginx http status code:$(curl -s -o /dev/null -w "%{http_code}" 127.0.0.1)
:
### KUBERNETES ON DEPLOYMENT DOCKER
echo|cat >./$_project/$nginx_deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $nginx_deployment
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
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "250m"
            memory: "256Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: $nginx_service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF
echo|cat >./$_project/ingress.$_project.yaml <<EOF
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
            name: $nginx_service
            port:
              number: 80
EOF

kubectl get all --namespace $_namespace

kubectl get pods,svc,deployment
kubectl apply  -f ./$_project/$nginx_deployment.yaml
kubectl apply  -f ./$_project/ingress.$_project.yaml
kubectl get pods,svc,deployment

# 404
echo nginx http status code:$(curl -s -o /dev/null -w "%{http_code}" 127.0.0.1)

# APPLY THE INGRESS CONTROLLER, THEN ADD /ETC/HOSTS MAPPING
echo "127.0.0.1 $localhostname" | sudo tee -a /etc/hosts
kubectl get pods,svc,deployment
:
# 200
echo nginx http status code:$(curl -s -o /dev/null -w "%{http_code}" $localhostname)

# kubectl get all --namespace $_namespace

:
helm uninstall $nginx_release --namespace $_namespace
kubectl delete namespace $_namespace
kubectl config use-context $default_cluster
kubectl config set-context --current --namespace default
sudo sed -i '' '/$localhostname/d' /etc/hosts

echo WE\'RE DONE
