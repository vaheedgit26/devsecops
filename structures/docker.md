## Dockerfile Manifest Security Pipeline 
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
    |                |
    |                |
    +----------------+
             |
             v
        Dockerfile Scan
             |
             v
       Docker Image Build
             |
             v
    +-------+-------+
    |               |
    v               v
Trivy Image       Generate SBOM
 Scan              sbom.json
    |               |
    +-------+-------+
            |
            v
       Sign Image
        (Cosign)
             |
             v
        Push to ECR
             |
             v
          ArgoCD
             |
             v
            EKS
```
