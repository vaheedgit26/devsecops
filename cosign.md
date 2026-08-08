## Step 1: Sign Your Image with Cosign    
**🔹 Option A: Key-based signing (most common in enterprises)**  

**1. Generate key pair**  
```bash
cosign generate-key-pair
```
Creates:  
- `cosign.key` (private)  
- `cosign.pub` (public)
  
**2. Sign your image (ECR example)**
```bash
cosign sign --yes \
  --key cosign.key \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app@sha256:<digest>
```
## 🔐 Step 2: Store Public Key in Kubernetes   
```bash
kubectl create secret generic cosign-public-key \
  --from-file=cosign.pub \
  -n kyverno
```
## 🛡️ Step 3: Kyverno Policy (verifyImages)  
Here is a **production-ready policy** 👇  
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-signed-images
spec:
  validationFailureAction: Enforce
  background: false

  rules:
  - name: verify-image-signature
    match:
      any:
      - resources:
          kinds:
          - Deployment

    verifyImages:
    - imageReferences:
      - "123456789012.dkr.ecr.*.amazonaws.com/*"

      verifyDigest: true   # ensures digest is used

      attestors:
      - entries:
        - keys:
            publicKeys: |-
              -----BEGIN PUBLIC KEY-----
              # paste cosign.pub content here
              -----END PUBLIC KEY-----
```

## 🚀 Step 4: (Better) Use Keyless Signing (OIDC / Sigstore)  
Instead of managing keys manually 👇  
```bash
cosign sign --yes \
  --keyless \
  123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app@sha256:<digest>
```
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-keyless-images
spec:
  validationFailureAction: Enforce
  background: false

  rules:
  - name: verify-keyless-signature
    match:
      any:
      - resources:
          kinds:
          - Deployment

    verifyImages:
    - imageReferences:
      - "123456789012.dkr.ecr.*.amazonaws.com/*"

      verifyDigest: true

      attestors:
      - entries:
        - keyless:
            subject: "repo:your-org/your-repo:*"
            issuer: "https://token.actions.githubusercontent.com"
```
