## Recommended flow  
```text
                         CI/CD PIPELINE
                              │
                              ▼
                         Dockerfile
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
         ┌──────────┐                    ┌────────────┐
         │ Hadolint │                    │ Conftest   │
         └────┬─────┘                    │ + OPA/Rego │
              │                          └─────┬──────┘
              │                                │
       Generic Dockerfile              Organization-specific
       best practices                  custom policies
              │                                │
              └───────────────┬────────────────┘
                              │
                         PASS / FAIL
                              │
                              ▼
                        docker build
                              │
                              ▼
                       Container Image
                              │
                              ▼
                     ┌────────────────┐
                     │ Trivy image    │
                     │     scan       │
                     └───────┬────────┘
                             │
                      PASS / FAIL
                             │
                             ▼
                    Cosign image signing
                             │
                             ▼
                           ECR
                             │
                             ▼
                       Argo CD deploy
                             │
                             ▼
                         Kubernetes
                             │
                             ▼
                       ┌───────────┐
                       │  Kyverno  │
                       └─────┬─────┘
                             │
             ┌───────────────┼────────────────┐
             │               │                │
             ▼               ▼                ▼
        Image policies   Pod policies     Signature
        ECR-only        Resources         verification
        Digest          Probes            Cosign
        No latest       SecurityContext
```
**What each stage should enforce**  
## 1. Hadolint  
```text
Dockerfile
    ↓
Hadolint
```
Use Hadolint for generic Dockerfile rules:  
- bad FROM usage  
- ADD instead of COPY  
- apt-get problems  
- shell best practices  
- package pinning  
- Dockerfile syntax/best practices  
- unnecessary layers  
etc.  

For example:  
```bash
hadolint --failure-threshold warning Dockerfile
```
If it fails:  
```text
❌ Pipeline stops
```
No image gets built.

## 2. OPA + Conftest  
This is where **your custom organization rules** belong.  

For example, you already have rules like:   
```rego
allowed_registries := [
    "123456789012.dkr.ecr.us-east-1.amazonaws.com",
    "123456789012.dkr.ecr.eu-west-1.amazonaws.com"
]
```
You can enforce:  
```text
FROM must use approved registry
```
You could also enforce organizational requirements such as:  
```text
FROM must specify tag or digest
USER must exist
USER must not be root
ENV must not contain secrets
Approved base images only
Approved package repositories
Required labels
Required metadata
```
Run:  
```bash
conftest test Dockerfile --policy policy/
```
If your Rego produces a deny, Conftest exits non-zero and:  
```text
❌ Pipeline stops
```
**Important**  
Don't duplicate Hadolint rules unnecessarily.  
For example, don't create your own Rego rule just to check:  

```text
ADD → COPY
```
if Hadolint already handles it.  
Instead:  
```text
Hadolint
   ↓
Generic Dockerfile security

OPA/Conftest
   ↓
Company-specific security requirements
```
That's much easier to maintain.  


## 3. Build the image  
Only after both checks pass:  
```bash
docker build \
  -t 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:${GIT_SHA} .
```
Now you have the actual artifact that will eventually run in EKS.  

## 4. Trivy  

Now scan the built image.  
For example:  
```bash
trivy image \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:${GIT_SHA}
```
If Trivy finds unacceptable vulnerabilities:  
```text
❌ Pipeline stops
```
This is important because Hadolint/OPA cannot tell you whether the final image contains:  
```text
openssl       CRITICAL
glibc         HIGH
curl          HIGH
Spring library HIGH
Log4j         CRITICAL
```
Trivy examines the actual image contents.   

## 5. Cosign

Only after the image passes Trivy should you sign it.

For example:
```bash
cosign sign --keyless \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app@sha256:<digest>
```
This is important:  
**Sign the digest**  
Not:   
```text
my-app:1.0
```
Prefer:  
```text
my-app@sha256:abcdef...
```
Because the digest uniquely identifies the exact image artifact.  

The sequence becomes:  
```text
Build
  ↓
Trivy
  ↓
Get digest
  ↓
Cosign sign digest
```

## 6. Push to ECR  

You can push the image before signing, because Cosign needs the image in the registry for normal registry-based signing workflows.  

So practically:  
```text
docker build  
     ↓
Trivy
     ↓
docker push ECR
     ↓
Cosign sign ECR digest
```

This is slightly different from the simplified diagram.  
A more precise flow is:  
```text
Dockerfile
    │
    ▼
Hadolint
    │
    ▼
OPA/Conftest
    │
    ▼
Docker Build
    │
    ▼
Trivy Image Scan
    │
    ▼
Push Image → ECR
    │
    ▼
Cosign Sign Image Digest
    │
    ▼
Deploy
```

## 7. Kyverno at EKS admission 

This is your last line of defense.  

Even though CI performed:  
```text
Hadolint
OPA
Trivy
Cosign
```
you should still enforce important rules with Kyverno.  

Why?

Because someone could potentially bypass your CI/CD pipeline and attempt:  
```bash
kubectl apply -f deployment.yaml
```
Kyverno prevents that.  

For your setup, Kyverno can enforce:  
```text
Deployment
   │
   ├── Main container image
   │      ├── ECR-only
   │      ├── digest required
   │      ├── no latest
   │      └── Cosign signature required
   │
   ├── Resources
   │      ├── CPU request 50m–500m
   │      ├── Memory request 64Mi–512Mi
   │      ├── CPU limit <= 500m
   │      └── Memory limit <= 512Mi
   │
   ├── Probes
   │      ├── livenessProbe
   │      └── readinessProbe
   │
   └── SecurityContext
          ├── runAsUser > 0
          ├── runAsGroup > 0
          ├── runAsNonRoot = true
          ├── readOnlyRootFilesystem = true
          ├── allowPrivilegeEscalation = false
          └── capabilities.drop = [ALL]
```

## One important improvement

I would actually add **SBOM generation** with Trivy.  

For example:  
```bash
trivy image \
  --format cyclonedx \
  --output sbom.json \
  "$IMAGE"
```
Then your supply-chain flow becomes:  
```text
Dockerfile
    │
    ├── Hadolint
    │
    └── OPA/Conftest
             │
             ▼
         Docker Build
             │
             ▼
          Trivy
        ┌────┴─────┐
        │          │
   Vulnerability   SBOM
      scan       generation
        │          │
        └────┬─────┘
             ▼
           ECR
             │
             ▼
        Cosign Sign
             │
             ▼
          Argo CD
             │
             ▼
            EKS
             │
             ▼
          Kyverno
             │
       ┌─────┴─────┐
       │           │
   Kubernetes   Signature
    policies    verification
```
**The key principle**  

Think of it as **three security layers:**    

**Layer 1 — Build-time**  
```text
Hadolint + OPA/Conftest
```
"Is this Dockerfile allowed?"  

**Layer 2 — Artifact-time**  
```text
Trivy + Cosign
```
"Is the image safe, and can we prove where it came from?"  

**Layer 3 — Runtime/admission-time**  
```text
Kyverno  
```
"Is this image and workload allowed to run in our EKS cluster?"     

That separation is cleaner than trying to make one tool do everything.  
