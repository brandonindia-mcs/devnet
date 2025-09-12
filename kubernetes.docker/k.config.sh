#!/usr/local/bin/bash
alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl delete"
alias kc="kubectl config"
alias ka="kubectl apply"
alias ke="kubectl expose"
alias kc="kubectl create"
alias kcfg="kubectl config"
### SHOW CURRENT CONTEXT

declare -A _VARIABLES
_VARIABLES[_project]=$_project
_VARIABLES[_cluster]=$_cluster
_VARIABLES[_namespace]=$_namespace
function print_vars {
  echo '************'
  for key in "${!_VARIABLES[@]}"; do
  echo "Key: $key: ${_VARIABLES[$key]}"
  done

  context
  echo '************'
}
function context {
  echo -e "\n$(echo -n context: && kubectl config current-context && echo -n namespace: && kubectl config view --minify --output 'jsonpath={..namespace}')"
}
