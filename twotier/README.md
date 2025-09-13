Component	Description
Resource Group	twotierrg
AKS Cluster	twotieraks
ACR Registry	twotieracr
PostgreSQL Server	twotierpgserver (Flexible Server v17)
Auth Service	auth-service
Transaction API	tx-service
Frontend	frontend
Public IP	ingresspublicip
Namespace	twotier
Docker Registry	docker.io/contosorealtime

twotier-app/
├── docker-compose.yml
├── auth-service/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── tx-service/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── frontend/
│   ├── Dockerfile
│   └── index.html
├── chart/twotier-app/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── secret.yaml
│       ├── auth-deployment.yaml
│       ├── auth-service.yaml
│       ├── tx-deployment.yaml
│       ├── tx-service.yaml
│       ├── frontend-deployment.yaml
│       ├── frontend-service.yaml
│       └── ingress.yaml