# Permissions
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
