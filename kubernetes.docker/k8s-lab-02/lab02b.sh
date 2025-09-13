#!/usr/local/bin/bash
. ./k.config.sh
# set -e


NAMESPACE="lab02b"
CLUSTER_NAME="lab-cluster"
INGRESS_NAME="lab-ingress"
APP_NAME="web-app"
NODE_PORT=30080

# CREATE OR REUSE CLUSTER
kubernetes_version=$(kubectl version|grep -i 'client version'|awk '{print $3}')\
  && echo "k8s version $kubernetes_version"\
  && kubectl config use-context ${kind}${_cluster} 2>/dev/null\
  || . ./lab-00.sh
kube_context

echo "🔄 Switching to Kind context '$CLUSTER_NAME'..."
kubectl config use-context "kind-${CLUSTER_NAME}"

echo "🔧 Ensuring namespace '$NAMESPACE' exists..."
kubectl get namespace $NAMESPACE >/dev/null 2>&1\
  || kubectl create namespace $NAMESPACE

echo "🚀 Deploying NGINX ingress controller..."
kubectl apply -n $NAMESPACE -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $INGRESS_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $INGRESS_NAME
  template:
    metadata:
      labels:
        app: $INGRESS_NAME
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
EOF

echo "🌐 Exposing ingress controller via NodePort..."
kubectl apply -n $NAMESPACE -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: $INGRESS_NAME
spec:
  type: NodePort
  selector:
    app: $INGRESS_NAME
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: $NODE_PORT
EOF

echo "📦 Deploying sample web app..."
kubectl apply -n $NAMESPACE -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: web
        image: hashicorp/http-echo
        args:
        - "-text=Hello from $NAMESPACE"
        ports:
        - containerPort: 5678
EOF

echo "🔓 Exposing web app via ClusterIP service..."
kubectl apply -n $NAMESPACE -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME
spec:
  selector:
    app: $APP_NAME
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5678
EOF

echo "🧭 Creating ingress rule..."
kubectl apply -n $NAMESPACE -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $APP_NAME-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $APP_NAME
            port:
              number: 80
EOF

echo "✅ Ingress web server deployed to '$NAMESPACE' using NodePort $NODE_PORT"
