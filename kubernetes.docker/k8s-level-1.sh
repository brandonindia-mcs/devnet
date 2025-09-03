export project=k8s-level-1
export service=nginx-service
export deployment=nginx-deployment
export namespace=lab
export release="ingress-nginx"
export chart="ingress-nginx/ingress-nginx"
export localhostname=nginx.local
mkdir -p ./$project

helm repo add $release https://kubernetes.github.io/ingress-nginx
helm repo update

kg namespace $namespace >/dev/null 2>&1 || kc namespace $namespace
kcfg set-context --current --namespace=$namespace

# ADD THE INGRESS-NGINX HELM REPO
helm install $release $chart \
  --namespace $namespace \
  --set controller.publishService.enabled=true
echo "⏳ Waiting for ingress controller pod to be ready..."
kubectl wait --namespace $namespace \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/name=$release \
  --timeout=120s
helm list --all-namespaces
kcfg view --minify | grep namespace

### KUBERNETES ON DEPLOYMENT DOCKER
echo|cat >./$project/$deployment.yaml <<EOF
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
---
apiVersion: v1
kind: Service
metadata:
  name: $service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF
echo|cat >./$project/ingress.yaml <<EOF
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
            name: nginx-service
            port:
              number: 80
EOF

ka -f ./$project/$deployment.yaml
ka -f ./$project/ingress.yaml
kg pods,svc,pods



# APPLY THE INGRESS CONTROLLER, THEN ADD /ETC/HOSTS MAPPING
echo "127.0.0.1 nginx.local" | sudo tee -a /etc/hosts


helm uninstall $release --namespace $namespace
kd namespace $namespace
kcfg set-context --current --namespace default
