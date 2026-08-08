| Tool               | Dockerfile | Terraform | Kubernetes YAML |    Container image |  
| ------------------ | ---------: | --------: | --------------: | -----------------: |  
| **Hadolint**       |          ✅ |         ❌ |               ❌ |                  ❌ |  
| **OPA + Conftest** |          ✅ |         ✅ |               ✅ |                  ❌ |  
| **Trivy**          |         ✅* | ❌/limited |               ✅ |                  ✅ |  
| **Checkov**        |          ❌ |         ✅ |               ✅ |                  ❌ |  
| **Kyverno**        |          ❌ |         ❌ |               ✅ | Image verification |  
| **tfsec**          |          ❌ |         ✅ |               ❌ |                  ❌ |  

*Trivy can scan Dockerfiles for certain misconfigurations, but **Hadolint is better suited specifically to Dockerfile linting.**  
**For your enterprise pipeline**  

Given the policies you've been building, I'd recommend:  
```text
                    Git Repository
                          │
          ┌───────────────┼────────────────┐
          │               │                │
          ▼               ▼                ▼
      Dockerfile       Terraform       K8s/Helm
          │               │                │
          ▼               ▼                ▼
      Hadolint          Checkov       Trivy config
          │               │                │
          ▼               │                ▼
      OPA/Conftest ◄──────┴───────────────►
          │
          ▼
       BUILD IMAGE
          │
          ▼
     Trivy Image Scan
          │
          ▼
      Cosign Sign
          │
          ▼
       Push ECR
          │
          ▼
       Argo CD
          │
          ▼
         EKS
          │
          ▼
       Kyverno
```
**What I would use for each**   

**Dockerfile:**  
```bash
hadolint Dockerfile
```
Then your custom Dockerfile Rego:  
```bash
conftest test Dockerfile --policy policy/dockerfile/
```
**Terraform:**
```bash
checkov -d terraform/
```
And if you have organization-specific Terraform rules:
```bash
conftest test terraform.json --policy policy/terraform/
```

**Kubernetes manifests:**  
```bash
trivy config ./k8s/
```
For your custom organizational Kubernetes rules, use:  
```bash
conftest test ./k8s/ --policy policy/kubernetes/  
```
And finally **Kyverno is the enforcement layer inside EKS**, so it protects you even if someone bypasses the CI pipeline.  

**One important distinction**  
Don't think of **Trivy** as only an image scanner.  

It has multiple scanning capabilities:  
```text
Trivy
 ├── Image scanning
 ├── Filesystem scanning
 ├── Kubernetes configuration scanning
 ├── Dockerfile/config scanning
 └── SBOM generation
```
But I would still keep **Hadolint for Dockerfiles** because it gives you Dockerfile-specific linting, while using **Trivy config** for Kubernetes configuration and **Checkov** for Terraform.

For your current DevSecOps design, a strong combination is:  

**Hadolint + Checkov + Trivy + OPA/Conftest + Cosign + Kyverno.**




