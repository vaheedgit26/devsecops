## Folder Structure
```text
repo/
│
├── apps/
│   |
│   └── backend/
│       |
│       ├── Chart.yaml
│       ├── values.yaml
│       |
│       └── templates/
│           |
│           ├── deployment.yaml
│           ├── service.yaml
│           └── ingress.yaml
│
├── security/
│   |
│   └── policies/
│       |
│       └── kubernetes/
│           |
│           ├── image.rego
│           ├── security-context.rego
│           └── resources.rego
│
└── .github/
    |
    └── workflows/
        |
        └── security.yaml
```

## For your EKS + ArgoCD setup, the recommended stack is:  
```text
Dockerfile
   |
   +-- Trivy config
   +-- Conftest


Terraform
   |
   +-- Checkov


Kubernetes
   |
   +-- Trivy config
   +-- Conftest


Container Image
   |
   +-- Trivy image scan
   +-- SBOM
   +-- Cosign


Runtime
   |
   +-- Kyverno
```
