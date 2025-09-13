apiVersion: v1
kind: Pod
metadata:
  name: twotier-smoke-test
  namespace: twotier
  labels:
    helm-test: smoke
spec:
  containers:
  - name: curl
    image: curlimages/curl
    command: ["sh", "-c"]
    args:
      - |
        curl -s http://auth-service/auth/login || exit 1
        curl -s http://tx-service/api/transactions || exit 1
  restartPolicy: Never
