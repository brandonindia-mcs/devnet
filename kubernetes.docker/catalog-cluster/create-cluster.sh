#!/usr/local/bin/bash
(
. ./k.config.sh
function yesno { read -p "$1 yes (default) or no: " && if [[ ${REPLY} = n ]] || [[ ${REPLY} = no ]]; then return 1; fi; return 0; }

kubectl config use-context docker-desktop
_project=catalog-cluster
lab_cluster="${1:-catalog-cluster}"
containerPort="${containerPort:-6443}"
hostPort="${hostPort:-6443}"
_cluster=$lab_cluster && kind=kind-

if [ -z "$1" ];then if yesno use default name: $_cluster?;then :;else exit 1;fi;fi
kube_context

# CREATE A 3-NODE CLUSTER
serviceSubnet=10.112.0.0/16
podSubnet=10.114.0.0/16
kubernetes_version=$(kubectl version|grep -i 'client version'|awk '{print $3}')\
  && echo "new kind cluster: k8s version $kubernetes_version"
echo|cat >./$_project/$_cluster-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  serviceSubnet: "$serviceSubnet"  # Avoids overlap with docker-desktop (10.96.0.0/12)
  podSubnet: "$podSubnet"
nodes:
  - role: control-plane
    image: kindest/node:$kubernetes_version
    extraPortMappings:
      - containerPort: $containerPort
        hostPort: $hostPort
        protocol: TCP
EOF

# NEW CLUSTER
kind create cluster -n $_cluster --config ./$_project/$_cluster-config.yaml\
  || kubectl config use-context ${kind}$_cluster
kube_context

echo $_project script finished
)