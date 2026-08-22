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
├── Pr-Check-Job
│     └── _go-pr-check.yml
│          ├── Gitleaks
│          ├── SonarQube
│          ├── Trivy FS
│          └── CodeQL
│
├── Dockerfile-Scan-Job
│     └── reusable-dockerfile-scan.yml
│          ├── Hadolint
│          └── Trivy Dockerfile
│
├── Image-Build-Job
│     └── reusable-image-build.yml
│          ├── Docker build
│          ├── Trivy image
│          └── Push to ECR
│                    │
│                    ▼
│             image_with_digest
│
└── Image-Sign-Job
      └── reusable-image-sign.yml
           └── Cosign keyless signing
```
