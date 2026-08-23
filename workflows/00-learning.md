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
