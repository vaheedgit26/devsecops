**When PR is created:**
```text
PR
 │
 ├── Gitleaks
 │     └── Secrets
 │
 ├── CodeQL
 │     └── SAST
 │
 ├── SonarQube
 │      └── Code quality/SAST
 ├── Trivy FS
       ├── IaC
       ├── secrets
       └── dependency vulnerabilities
```
**After PR Merged:**
```text
Build Docker image
       │
       ▼
Trivy image
       │
       ├── OS vulnerabilities
       ├── Application dependencies
       └── Image contents
```
