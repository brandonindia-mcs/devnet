helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

helm upgrade --install kubernetes-dashboard \
  kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --create-namespace

# START LOCAL PROXY
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

# browser: https://localhost:8443

### BEARER TOKEN
# Step 1: Create a Service Account for Dashboard Access
# This creates a service account named k8sadmin in the kube-system namespace.
kubectl create serviceaccount k8sadmin -n kube-system


# Step 2: Bind It to Cluster Admin Role
# This gives the service account full admin privileges—fine for local use, but not recommended for production.
kubectl create clusterrolebinding k8sadmin \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:k8sadmin


# Step 3: Retrieve the Bearer Token
# This will output a valid Bearer token you can use to log into the Dashboard.
# For Kubernetes versions prior to 1.24:
kubectl -n kube-system get secret \
  | grep k8sadmin

kubectl -n kube-system describe secret <secret-name> \
  | grep 'token:'

# For Kubernetes 1.24+, tokens are no longer stored in secrets. Instead, use:
kubectl create token k8sadmin -n kube-system

