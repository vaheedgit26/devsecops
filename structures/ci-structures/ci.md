## CI Pipeline
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
           ( Status checks at Github Repo level )
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
                                       ▼
                              Cosign SBOM Attest
                                       │
                                       ▼
                                  Push to ECR
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
                                  GitOps repo
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
                             FAIL             PASS
                              │                 │
                              ▼                 ▼
                         Pod rejected       Pod admitted
                                                │
                                                ▼
                                          EKS Pod Running
```
