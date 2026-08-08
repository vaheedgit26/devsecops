## Hadolint  
```text
                    Dockerfile
                        │
                        ▼
                   Hadolint
                        │
                ┌───────┴───────┐
                │               │
             issues           clean
                │               │
             ❌ FAIL          Build
                                │
                                ▼
                           Trivy image
                                │
                       ┌────────┴────────┐
                       │                 │
                  vulnerabilities      clean
                       │                 │
                    ❌ FAIL          Cosign sign
                                         │
                                         ▼
                                        ECR
```
For example:  
```bash
hadolint --failure-threshold error Dockerfile
```
This means:  
```text
ERROR       → FAIL
WARNING     → don't fail
INFO        → don't fail
STYLE       → don't fail
```
Or stricter:  
```bash
hadolint --failure-threshold warning Dockerfile
```
Now:  
```text
ERROR       → FAIL
WARNING     → FAIL
INFO        → don't fail
STYLE       → don't fail
```
**Example GitHub Actions**  
```yaml
name: Container Security

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  docker-security:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Hadolint
        uses: hadolint/hadolint-action@v3.1.0
        with:
          dockerfile: Dockerfile
          failure-threshold: error

      - name: Build image
        run: |
          docker build -t my-app:${{ github.sha }} .

      - name: Trivy image scan
        run: |
          trivy image \
            --severity HIGH,CRITICAL \
            --exit-code 1 \
            my-app:${{ github.sha }}
```
Notice the important difference:  
```yaml
failure-threshold: error
```
for Hadolint, and:   
```bash
--exit-code 1
```
> This is the approach I'd recommend for your EKS project: fail early with Hadolint, then build, scan the actual image with Trivy, sign it with Cosign, push to ECR, and finally let Kyverno enforce the rules at cluster admission.
