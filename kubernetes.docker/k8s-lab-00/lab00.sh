#!/usr/local/bin/bash
. ./k.config.sh
kubectl config use-context docker-desktop
_project=k8s-lab-00
lab_cluster="${1:-lab-cluster}"
containerPort="${containerPort:-30080}"
hostPort="${hostPort:-30080}"
export _cluster=$lab_cluster && kind=kind-
kube_context

# CREATE A 3-NODE CLUSTER
kubernetes_version=$(kubectl version|grep -i 'client version'|awk '{print $3}')\
  && echo "new kind cluster: k8s version $kubernetes_version"
echo|cat >./$_project/$_cluster-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  serviceSubnet: "10.97.0.0/16"  # Avoids overlap with docker-desktop (10.96.0.0/12)
  podSubnet: "10.98.0.0/16"
nodes:
- role: control-plane
  image: kindest/node:$kubernetes_version
- role: worker
  image: kindest/node:$kubernetes_version
- role: worker
  image: kindest/node:$kubernetes_version
EOF

# NEW CLUSTER
kind create cluster -n $_cluster --config ./$_project/$_cluster-config.yaml\
  || kubectl config use-context ${kind}$_cluster
kube_context

echo $_project script finished
