# 🚀 Rideshare Infrastructure

This repository contains the Kubernetes infrastructure and deployment configuration for the Rideshare microservices ecosystem. It includes manifest files, secrets injection, ingress rules, storage classes, and global routing setup using Azure Front Door.

---

## 🧱 Structure

```bash
rideshare-infrastructure/
├── azure-setup/
│   ├── configure-frontdoor.sh         # Automates Azure Front Door provisioning
│   ├── create-aks-cluster.sh
│    └── frontdoor.env                  # Environment variables for global routing
├── data-layer/
│   ├── postgresql-*.yaml              # PostgreSQL primary & replica StatefulSets
│   ├── redis-*.yaml                   # Redis StatefulSet, headless service & configMap
├── networking/
│   └── ingress-rules.yaml             # Ingress routing configuration
├── storage/
│   └── storage-classes.yaml           # Persistent volume provisioning
└── .github/workflows/
    └── deploy.yml                     # CI/CD pipeline for cluster provisioning
```

⚙️ GitHub Actions Workflow
deploy.yml
Triggers on:

push to main affecting infra directories

Manual dispatch via workflow_dispatch

Jobs:

deploy-infrastructure: Validates manifests, injects secrets, applies workloads & ingress

setup-frontdoor: Runs only on manual trigger to provision Azure Front Door (with health probes & routing)

🌍 Global Routing via Azure Front Door
The script azure-setup/configure-frontdoor.sh provisions:

Front Door profile & endpoint

Health-probed origin groups spanning West US & East US ingress domains

API traffic route forwarding (/api/\*) via HTTPS

Environment values are loaded from frontdoor.env.

🔒 Secrets Management
Secrets are injected using kubectl create secret:

Shared secrets (JWT_SECRET_KEY, REDIS_URL, etc.)

Per-microservice secrets (USER_DATABASE_URL, SENDGRID_API_KEY, etc.)

Configured for dry-run validation and namespaced application

📦 Microservices
Infrastructure supports the following workloads:

user-service

payment-service

ride-matching-service

notification-service

Each microservice is deployed via its own Kubernetes manifest.
