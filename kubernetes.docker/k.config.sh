#!/usr/bin/env bash
alias k="kubectl"
alias kg="kubectl get"
alias kgr="kubectl get rs"
alias kgns="kubectl get namespace"
alias kgp="kubectl get pod"
alias kgd="kubectl get deployment"
alias kgrs="kubectl get rs"
alias kgsts="kubectl get sts"
alias kgs="kubectl get svc"
alias kgi="kubectl get ingress"

alias kd="kubectl delete"
alias kdi="kubectl delete ingress"

alias kc="kubectl config"
alias ka="kubectl apply"
alias ke="kubectl expose"
alias kc="kubectl create"
alias kcfg="kubectl config"
alias kl="kubectl logs"


alias kget="kubectl get all"

alias kdesc="kubectl describe"
alias kconfig="kubectl config view"
alias khelp="kubectl api-resources"
alias context=kube_context
alias kclear="kd all --all"

function print_vars {
  # declare -A _VARIABLES
  # _VARIABLES[_project]=$_project
  # _VARIABLES[_cluster]=$_cluster
  # _VARIABLES[_namespace]=$_namespace
  # for key in "${!_VARIABLES[@]}"; do
  # echo "Key: $key: ${_VARIABLES[$key]}"
  # done
  echo -e "_project:      $_project"
  echo -e "_cluster:      $_cluster"
  echo -e "_namespace:    $_namespace"
}
function kube_context {
  echo '************************************'
  print_vars
  echo '************************************'
  echo -e "$(echo -ne Cluster Context:\\t && kubectl config current-context && echo -n Current Namespace:\\t && kubectl config view --minify --output 'jsonpath={..namespace}')"
  echo '************************************'
  # kubectl get deployment,ingress,svc,pods
  kubectl get all -o wide
}
echo $0 called k.config.sh
# CALLING_SCRIPT_NAME=$(ps -o comm= $PPID)
# echo $(ps -o comm= $PPID) called k.config.sh
