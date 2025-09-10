alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl delete"
alias kc="kubectl config"
alias ka="kubectl apply"
alias ke="kubectl expose"
alias kc="kubectl create"
alias kcfg="kubectl config"
### SHOW CURRENT CONTEXT
function context {
  echo -e "\n$(echo -n context: && kubectl config current-context && echo -n namespace: && kubectl config view --minify --output 'jsonpath={..namespace}')"
}
