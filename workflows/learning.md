```text
01-ci-pr-backend.yml
        │
        │  MAXIMUM AVAILABLE
        │
        ├── contents: read
        ├── pull-requests: read
        └── security-events: write
        │
        ▼
_go-pr-check.yml
        │
        │  No need to redefine permissions
        │
        ├──────────────┬───────────────┬───────────────┐
        ▼              ▼               ▼               ▼
   Gitleaks        SonarQube       Trivy FS        CodeQL
        │              │               │               │
        ▼              ▼               ▼               ▼
 contents:read    contents:read   contents:read   contents:read
 security-events  (if needed)     security-events security-events
 ```
