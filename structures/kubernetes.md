
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
    |                |
    |                |
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
