```text
                         PR
                          │
          ┌───────────────┼────────────────┐
          │               │                │
          ▼               ▼                ▼
       Gitleaks          CodeQL         SonarQube
       Secrets            SAST         Code Quality
          │               │                │
          └───────────────┼────────────────┘
                          │
                          ▼
                     Trivy FS
                          │
              ┌───────────┼───────────┐
              ▼           ▼           ▼
            SCA         Secrets      IaC
                          │
                          ▼
                     PR Security
                          │
                          ▼
                        MERGE
                          │
                          ▼
                    Docker Build
                          │
                          ▼
                    Trivy Image
                          │
                 ┌────────┼────────┐
                 ▼        ▼        ▼
                OS       App      Image
              packages   deps     config
                          │
                          ▼
                         ECR
```
**After PR merged:**
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
