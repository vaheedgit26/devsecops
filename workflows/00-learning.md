# 1. Permissions:   
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

## 2. CI Flow:    
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

## 3. Main Workflow:  
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

## 4. For your security architecture:  
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

## 4. Application repository:  
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

## 6. GitOps repository:  
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
## 7. Final deployment chain:
```text
                 APPLICATION REPO
                       │
                       ▼
                 Developer Push
                       │
                       ▼
                _go-pr-check.yml
                       │
             ┌─────────┴──────────┐
             ▼                    ▼
         SAST / Secrets       FS Scan
             │
             ▼
              _go-build.yml
                   │
       ┌───────────┼─────────────┐
       ▼           ▼             ▼
 Dockerfile     Build         Security
   Scan         Image          Gates
                   │
                   ▼
                 Trivy
                   │
                   ▼
                 ECR
                   │
                   ▼
              Image Digest
                   │
          ┌────────┼─────────┐
          ▼        ▼         ▼
       Cosign     SBOM     Attestation
          │
          └────────┬────────┘
                   ▼
            Update GitOps
                   │
                   ▼
            Create GitOps PR
                   │
                   ▼
          ┌──────────────────┐
          │   GITOPS REPO    │
          │                  │
          │ values.yaml      │
          │ Helm templates   │
          └────────┬─────────┘
                   │
                   ▼
              GitOps CI
                   │
          ┌────────┼──────────┐
          ▼        ▼          ▼
       Helm      Trivy     Conftest
      Template    Config      OPA
          │        │          │
          └────────┼──────────┘
                   ▼
              Kyverno CLI
                   │
                   ▼
                PASS
                   │
                   ▼
               PR Merge
                   │
                   ▼
                Argo CD
                   │
                   ▼
                  EKS
                   │
                   ▼
                Kyverno
                   │
          ┌────────┼─────────┐
          ▼        ▼         ▼
       Signature  SBOM      Image
       Verify    Verify     Policy
                   │
                   ▼
              Application
```

## 8. Application CI:  
```text
Application repo
      │
      ▼
_go-build.yml
      │
      ├── Build
      ├── Scan
      ├── Push
      ├── Sign
      ├── SBOM
      └── Create GitOps PR
```

## 9. GitOps CI:  
```text
GitOps repo
      │
      ▼
GitOps PR
      │
      ├── Helm lint
      ├── Helm template
      ├── Trivy config
      ├── OPA/Conftest
      └── Kyverno CLI
      │
      ▼
    Merge
      │
      ▼
   Argo CD
      │
      ▼
     EKS
      │
      ▼
   Kyverno
```

## 10. Directory Structure:  
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
│           └── ingress.yaml
│
├── envs/
│   ├── dev/
│   │   └── values-backend.yaml
│   │
│   ├── qa/
│   │   └── values-backend.yaml
│   │
│   └── prod/
│       └── values-backend.yaml
│
└── .github/
    └── workflows/
        └── gitops-ci.yml
```
