```text
                         DEVELOPER
                             │
                             │ Pull Request
                             ▼
                    ┌─────────────────┐
                    │   GitHub PR     │
                    └────────┬────────┘
                             │
              ┌──────────────┼────────────────┐
              │              │                │
              ▼              ▼                ▼
          Gitleaks         CodeQL          SonarQube
          Secrets           SAST          Quality/SAST
              │              │                │
              └──────────────┼────────────────┘
                             │
                             ▼
                         Trivy FS
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
             SCA           Secrets         IaC
                             │
                             ▼
                       PR SECURITY GATE
                    GitHub Required Checks
                             │
                   ┌─────────┴─────────┐
                   │                   │
                  FAIL                PASS
                   │                   │
                   ▼                   ▼
                 ❌ STOP        Dockerfile Security
                               ┌────────┴────────┐
                               │                 │
                               ▼                 ▼
                           Hadolint          Trivy Config
                               │                 │
                               └────────┬────────┘
                                        │
                                  Dockerfile Gate
                                        │
                               ┌────────┴────────┐
                               │                 │
                              FAIL              PASS
                               │                 │
                               ▼                 ▼
                            ❌ STOP            PR MERGE
                                                   │
                                                   ▼
                                            Docker Build
                                                   │
                                                   ▼
                                          Trivy Image Scan
                                                   │
                              ┌────────────────────┼────────────────────┐
                              ▼                    ▼                    ▼
                         OS packages        App dependencies        Image config
                              │                    │                    │
                              └────────────────────┼────────────────────┘
                                                   ▼
                                            IMAGE SECURITY GATE
                                                   │
                                         ┌─────────┴─────────┐
                                         │                   │
                                        FAIL                PASS
                                         │                   │
                                         ▼                   ▼
                                      ❌ STOP              ECR Push
                                                               │
                                                               ▼
                                                        Get Image Digest
                                                               │
                                                               ▼
                                                        Cosign Sign Digest
                                                               │
                                                               ▼
                                                        Generate SBOM
                                                        CycloneDX
                                                               │
                                                               ▼
                                                   Cosign SBOM Attestation
                                                               │
                                                               ▼
                                                    Update Helm values.yaml
                                                   repository + digest
                                                               │
                                                               ▼
                                                 Kubernetes Manifest Scan
                                                        Trivy Config
                                                               │
                                                   ┌───────────┴───────────┐
                                                   │                       │
                                                  FAIL                    PASS
                                                   │                       │
                                                   ▼                       ▼
                                                ❌ STOP                Git Commit
                                                                            │
                                                                            ▼
                                                                       GitOps Repo
                                                                            │
                                                                            ▼
                                                                         Argo CD
                                                                            │
                                                                            ▼
                                                                  Kubernetes API Server
                                                                            │
                                                                            ▼
                                                                       KYVERNO
                                                                            │
                                            ┌─────────────────────┌───────────────┐-----------------------┐
                                            │                     │               │                       │
                                            ▼                     ▼               ▼                       ▼
                                         ECR image?        Digest used?       Image signed?         SBOM attestation?
                                            │                                                             │
                                            └────────────────────────────────────────────────────────────-┘                                                                                                                                                            │
                                                                ┌──────────┴─────────┐
                                                                │                    │
                                                               FAIL                 PASS
                                                                │                    │
                                                                ▼                    ▼
                                                          ❌ Pod rejected       Pod admitted
                                                                                     │
                                                                                     ▼
                                                                                  EKS Pod
```
