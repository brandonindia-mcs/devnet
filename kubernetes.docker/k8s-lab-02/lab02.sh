#!/usr/local/bin/bash
. ./k.config.sh

# CREATE OR REUSE CLUSTER
kubernetes_version=$(kubectl version|grep -i 'client version'|awk '{print $3}')\
  && echo "k8s version $kubernetes_version"\
  && kubectl config use-context ${kind}${_cluster} 2>/dev/null\
  || . ./lab00.sh
kube_context

export _project=k8s-lab-02

lab_cluster=lab-cluster
export _cluster=$lab_cluster && kind=kind-
export _namespace=lab02

localhostname=nginx.local
port=80
target_port=80
node_port=30080

nginx_release="ingress-nginx"
nginx_chart="ingress-nginx/ingress-nginx"

nginx_service=$_namespace-nginx-service
nginx_deployment=$_namespace-nginx-deployment
mkdir -p ./$_project
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
        - containerPort: $target_port
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
  - port: $target_port
    targetPort: $target_port
    nodePort: $node_port
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
              number: $port
EOF

# kubectl get namespace $_namespace >/dev/null 2>&1 || kubectl create namespace $_namespace
# kubectl config set-context --current --namespace=$_namespace
:
kubectl get namespace $_namespace\
  || kubectl create namespace $_namespace\
  && kubectl config set-context --current --namespace=$_namespace
kubectl get all --namespace $_namespace
kube_context

# ERROR | 000 ) 404
echo nginx http status code for 127.0.0.1:$(curl -s -o /dev/null -w "%{http_code}" 127.0.0.1)
:
echo -e "installing $nginx_release $nginx_chart..."
helm repo add $nginx_release https://kubernetes.github.io/ingress-nginx
helm repo update
# INSTALL THE INGRESS-NGINX CONTROLLER
:
helm install $nginx_release $nginx_chart \
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
echo nginx http status code for 127.0.0.1:$(curl -s -o /dev/null -w "%{http_code}" 127.0.0.1)
# 000
echo nginx http status code for $localhostname:$(curl -s -o /dev/null -w "%{http_code}" $localhostname)
:
kubectl get pods,svc,deployment
kubectl apply  -f ./$_project/$nginx_deployment.yaml
kubectl apply  -f ./$_project/ingress.$_project.yaml
kubectl get pods,svc,deployment


# 404
echo nginx http status code for 127.0.0.1:$(curl -s -o /dev/null -w "%{http_code}" 127.0.0.1)
echo nginx http status code for $localhostname:$(curl -s -o /dev/null -w "%{http_code}" $localhostname)
:
# APPLY THE INGRESS CONTROLLER, THEN ADD /ETC/HOSTS MAPPING
echo "127.0.0.1 $localhostname" | sudo tee -a /etc/hosts
kubectl get pods,svc,deployment
:
# 200
echo nginx http status code for 127.0.0.1:$(curl -s -o /dev/null -w "%{http_code}" 127.0.0.1)
echo nginx http status code for $localhostname:$(curl -s -o /dev/null -w "%{http_code}" $localhostname)

# kubectl get all --namespace $_namespace

:
helm uninstall $nginx_release --namespace $_namespace
kubectl delete namespace $_namespace
kubectl config use-context $default_cluster
kubectl config set-context --current --namespace default
sudo sed -i '' "/$localhostname/d" /etc/hosts
if ! `grep $localhostname /etc/hosts`; then echo $localhostname removed; fi

echo $_project script finished
