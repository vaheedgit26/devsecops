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
                     PR Security ( Status checks at Github repo level )
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
