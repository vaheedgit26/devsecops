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
## Kubernetes Manifest Security Pipeline  
```text
Developer
    |
    |
GitHub Pull Request
    |
    |
GitHub Actions
    |
    +----------------+
    |                |
    v                v
 Trivy config     OPA Conftest
    |                |
    |                |
 Built-in          Company
 checks            policies
    |
    |
    +----------------+
             |
             v
        Helm Template
             |
             v
       Kubernetes YAML
             |
             v
          ArgoCD
             |
             v
            EKS
             |
             v
          Kyverno
     (runtime enforcement)  
```
