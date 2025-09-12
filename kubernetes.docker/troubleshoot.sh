

### GET INFO ON EVERYTHING
kg all --all-namespaces
### GET RESOURCES IN NAMESPACE
kg all --namespace $namespace
k get namespaces
kcfg get-contexts
kg node,pod,svc,deployment,replicaset --namespace default
kg node,pod,svc,deployment,replicaset --namespace $namespace

### SHOW CURRENT CONTEXT
kubectl config current-context
# NAMESPACE
kubectl config view --minify --output 'jsonpath={..namespace}'
# CONTEXT FULL DETAILS
kubectl config view --minify

### SET CONTEXT
kcfg use-context kind-$cluster
kg namespace $namespace\
  || kc namespace $namespace\
  && kcfg set-context --current --namespace $namespace

  
## DELETE CLUSTER AND SET DEFAULT
kind delete cluster -n $cluster\
  && kcfg use-context docker-desktop\
  && kcfg set-context --current --namespace default


### RESET NAMESPACE
cluster=docker-desktop
namespace=default
kcfg use-context $cluster

kd all --all --namespace=$namespace
unset namespace

### DELETE NAMESPACE
namespace=lab02
kd namespace $namespace
unset namespace

### RESET TO DEFAULT AND DELETE
kcfg use-context docker-desktop
kcfg set-context --current --namespace default
kind delete cluster -n $cluster


## REMOVE A HELM AT NAMESPACE
helm uninstall $helm_release \
  --namespace $namespace

helm list --all-namespaces
helm uninstall my-redis --namespace default


# 3. Context Not Set to Namespace
# If you're using kubectl interactively, you might want to set your context to a specific namespace:
kubectl config set-context --current --namespace=$namespace

# 4. Kind Cluster Misconfiguration
# Ensure your Kind cluster is running and healthy:
kubectl cluster-info --context kind-$cluster


kcfg use-context docker-desktop
helm list --all-namespaces
kcfg set-context --current --namespace default

kcfg use-context kind-lab-cluster
namespace=lab02
kcfg set-context --current --namespace default
kd all --all --namespace=$namespace
kd namespace $namespace

helm uninstall ingress-nginx \
  --namespace $namespace