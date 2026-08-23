# Permissions:   
```text
01-ci-pr-backend.yml  (Top level Caller)
        │
        │  MAXIMUM AVAILABLE
        │
        ├── contents: read
        ├── pull-requests: read
        ├── id-token: read
        ├── actions: read
        └── security-events: write
        │
        ▼
_go-pr-check.yml
        │
        │  No need to redefine permissions (Middle Layer)
        │
        ├──────────────┬───────────────┬───────────────┐
        ▼              ▼               ▼               ▼
   Gitleaks        SonarQube       Trivy FS        CodeQL     (Reusable Workflows)
        │              │               │               │
        ▼              ▼               ▼               ▼
 contents:read    contents:read   contents:read   contents:read
 security-events  (if needed)     security-events security-events
 ```

## CI Flow:    
```text
_go-build.yml
│
├── _go-pr-check.yml
│     ├── Gitleaks
│     ├── SonarQube
│     ├── Trivy FS
│     └── CodeQL
│
├── reusable-dockerfile-scan.yml
│     ├── Hadolint
│     ├── Trivy Dockerfile
│     └── OPA/Conftest
│
├── reusable-image-build.yml
│     ├── Docker Build
│     ├── Trivy Image Scan
│     └── ECR Push
│
├── reusable-image-sign.yml
│     └── Cosign Sign
│
└── reusable-sbom-attestation.yml
      ├── Trivy → CycloneDX SBOM
      ├── Cosign Attest
      └── Upload SBOM Artifact
```

## Main Workflow:  
```text
02-ci-backend.yml
        │
        ▼
   _go-build.yml
        │
        ├── PR/SAST
        ├── Dockerfile security
        ├── Build + image scan + ECR
        ├── Cosign signing
        └── SBOM + attestation
```

## For your security architecture:  
```text
| Stage        | Tool         | Purpose                        |
| ------------ | ------------ | ------------------------------ |
| Dockerfile   | Hadolint     | Dockerfile best practices      |
| Dockerfile   | Trivy config | Dockerfile misconfiguration    |
| Dockerfile   | Conftest     | Organization-specific rules    |
| Image        | Trivy        | Vulnerability scanning         |
| Image        | Cosign       | Image signing                  |
| Image        | Trivy        | CycloneDX SBOM                 |
| Image        | Cosign       | SBOM attestation               |
| Helm/K8s     | Trivy config | Kubernetes misconfiguration    |
| Rendered K8s | Conftest/OPA | Organization-specific policies |
| Rendered K8s | Kyverno CLI  | Same policies as admission     |
| Cluster      | Kyverno      | Runtime admission enforcement  |
```
## Application repository:  
```text
application-repo/
│
├── backend/
│   ├── Dockerfile
│   ├── go.mod
│   └── ...
│
└── .github/
    └── workflows/
        ├── _go-pr-check.yml
        ├── _go-build.yml
        │
        ├── reusable-gitleaks.yml
        ├── reusable-sonarqube.yml
        ├── reusable-trivy-fs.yml
        ├── reusable-codeql.yml
        │
        ├── reusable-dockerfile-scan.yml
        ├── reusable-image-build.yml
        ├── reusable-image-sign.yml
        └── reusable-sbom-attestation.yml
```

## GitOps repository:  
```text
gitops-repo/
│
├── charts/
│   └── backend/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           ├── serviceaccount.yaml
│           └── ...
│
└── envs/
    ├── dev/
    │   └── backend/
    │       └── values.yaml
    │
    ├── qa/
    │   └── backend/
    │       └── values.yaml
    │
    └── prod/
        └── backend/
            └── values.yaml
```
