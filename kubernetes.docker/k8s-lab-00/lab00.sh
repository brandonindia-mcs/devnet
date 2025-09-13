#!/usr/local/bin/bash
. ./k.config.sh
_project=k8s-lab-00
lab_cluster="${1:-lab-cluster}"
export _cluster=$lab_cluster && kind=kind-
kube_context

# CREATE A 3-NODE CLUSTER
kubernetes_version=$(kubectl version|grep -i 'client version'|awk '{print $3}')\
  && echo "new kind cluster: k8s version $kubernetes_version"
echo|cat >./$_project/$_cluster-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
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
