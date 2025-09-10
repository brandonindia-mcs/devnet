

### GET INFO ON EVERYTHING
kg all --all-namespaces
### GET RESOURCES IN NAMESPACE
kg all --namespace $_namespace
k get namespaces
kcfg get-contexts
kg node,pod,svc,deployment,replicaset --namespace default
kg node,pod,svc,deployment,replicaset --namespace $_namespace

### SHOW CURRENT CONTEXT
kubectl config current-context
# NAMESPACE
kubectl config view --minify --output 'jsonpath={..namespace}'
# CONTEXT FULL DETAILS
kubectl config view --minify

### SET CONTEXT
kcfg use-context kind-$_cluster
kg namespace $_namespace\
  || kc namespace $_namespace\
  && kcfg set-context --current --namespace $_namespace


### DELETE ALL IN NAMESPACE
kd all --all --namespace=$_namespace
### DELETE NAMESPACE
kd namespace $_namespace
### RESET TO DEFAULT AND DELETE
kcfg use-context docker-desktop
kcfg set-context --current --namespace default
kind delete cluster -n $_cluster


## REMOVE A HELM AT NAMESPACE
helm uninstall $_helm_release \
  --namespace $_namespace

  
## DELETE CLUSTER AND SET DEFAULT
kind delete cluster -n $_cluster\
  && kcfg use-context docker-desktop\
  && kcfg set-context --current --namespace default

helm list --all-namespaces
helm uninstall my-redis --namespace default


# 3. Context Not Set to Namespace
# If you're using kubectl interactively, you might want to set your context to a specific namespace:
kubectl config set-context --current --namespace=$_namespace

# 4. Kind Cluster Misconfiguration
# Ensure your Kind cluster is running and healthy:
kubectl cluster-info --context kind-$_cluster
