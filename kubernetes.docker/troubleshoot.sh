k get all -n default
k delete all --all -n default
helm list --all-namespaces
helm uninstall my-redis --namespace default

k delete namespace $_namespace


k config get-contexts
kubectl config use-context docker-desktop
kubectl config use-context kind-kind
