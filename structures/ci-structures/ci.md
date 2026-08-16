## 1. Short form CI  
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
## 2. Long form CI
```text
                         DEVELOPER
                             │
                             │ Pull Request
                             ▼
                    ┌──────────────────┐
                    │   GitHub PR      │
                    └────────┬─────────┘
                             │
              ┌──────────────┼────────────────┐
              │              │                │
              ▼              ▼                ▼
          Gitleaks         CodeQL          SonarQube
          Secrets           SAST          Quality/SAST
              │              │                │
              └──────────────┼────────────────┘
                             ▼
                        Trivy FS
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
             SCA           Secrets          IaC
                             │
                             ▼
                       SECURITY GATE
                             │
                   ┌─────────┴─────────┐
                   │                   │
                  FAIL                PASS
                   │                   │
                   ▼                   ▼
                ❌ STOP            PR MERGE
                                       │
                                       ▼
                              Docker Image Build
                                       │
                                       ▼
                              Trivy Image Scan
                                       │
                         ┌─────────────┼─────────────┐
                         ▼             ▼             ▼
                    OS packages   App dependencies  Config
                                       │
                                       ▼
                              CycloneDX SBOM
                                       │
                                       ▼
                              Cosign Image Sign
                                       │
                              Cosign SBOM Attest
                                       │
                                       ▼
                                     ECR
                                       │
                                       ▼
                              Get Image Digest
                                       │
                                       ▼
                          Update Helm values.yaml
                          image.repository + digest
                                       │
                                       ▼
                                   Git commit
                                       │
                                       ▼
                                  GitHub repo
                                       │
                                       ▼
                                   Argo CD
                                       │
                                       ▼
                              Kubernetes manifests
                                       │
                                       ▼
                                    EKS API
                                       │
                                       ▼
                                  KYVERNO
                                       │
                       ┌───────────────┼────────────────┐
                       ▼               ▼                ▼
                 ECR image?       Digest used?     Image signed?
                       │               │                │
                       └───────────────┼────────────────┘
                                       ▼
                                SBOM attestation?
                                       │
                              ┌────────┴────────┐
                              │                 │
                            PASS              FAIL
                              │                 │
                              ▼                 ▼
                         Pod admitted       Pod rejected
                              │
                              ▼
                           EKS Pod
```
