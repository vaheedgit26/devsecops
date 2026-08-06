## Step 0: Understand tag vs digest  
Most developers use:  
```yaml
image: backend:v1.0.5
```
This is a tag.  
A tag is just a pointer.  
Example:  
```text
backend:v1.0.5
          |
          |
          v
sha256:111aaa
```
Tomorrow:  
```text
backend:v1.0.5
          |
          |
          v
sha256:999bbb
```
The same tag points to a different image.  

A digest is immutable:  
```yaml
image: backend@sha256:111aaa
```
Meaning:  "Run exactly this image."  

## Step 1: Install Cosign  
Linux:  
```bash
curl -O -L https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
chmod +x cosign-linux-amd64
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
```
Verify:  
```bash
cosign version
```

## Step 2: Generate Cosign keys  
```bash
cosign generate-key-pair
```
Output:  
```text
cosign.key
cosign.pub
```
You now have:  
```text
Private key
------------
cosign.key

Used by:
GitHub Actions
Developer pipeline


Public key
------------
cosign.pub

Used by:
Kyverno
```

**Important**  
Never put:   
```text
cosign.key
```
Inside Git.  

Store it in:  
```text
GitHub Secrets
```
Example:  
```text
COSIGN_PRIVATE_KEY
COSIGN_PASSWORD
```

## Step 3: Build Docker image  
Your application:  
```text
backend/
 |
 Dockerfile
```
Build:  
```bash
docker build -t backend:v1.0.0 .
```
Check:  
```bash
docker images
```
Output:  
```text
backend    v1.0.0
```

## Step 4: Login to ECR  
Account:  
```text
123456789012
```
Region:  
```text
us-east-1
```

Login:  
```bash
aws ecr get-login-password \
--region us-east-1 \
| docker login \
--username AWS \
--password-stdin \
123456789012.dkr.ecr.us-east-1.amazonaws.com
```

## Step 5: Tag image for ECR  
Your local image:    
```text
backend:v1.0.0
```

ECR image:  
```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend:v1.0.0
```
Tag:  
```bash
docker tag \
backend:v1.0.0 \
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend:v1.0.0
```

## Step 6: Push image to ECR  
```bash
docker push \
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend:v1.0.0
```
Now ECR has:  
```text
backend:v1.0.0
```

## Step 7: Get image digest  
This is the most important step.  

Run:  
```bash
docker inspect \
--format='{{index .RepoDigests 0}}' \
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend:v1.0.0
```
Output:  
```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend@sha256:8f4a2c9xxxx
```
The important part:  
```text
sha256:8f4a2c9xxxx
```
This is your immutable image identity.  

## Alternative: Get digest using AWS CLI  
You can also use:  
```bash
aws ecr describe-images \
--repository-name backend \
--image-ids imageTag=v1.0.0 \
--query 'imageDetails[0].imageDigest' \
--output text
```
Output:  
```text
sha256:8f4a2c9xxxx
```

## Step 8: Sign the image using Cosign  
Command:  
```bash
cosign sign \
--key cosign.key \
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend@sha256:8f4a2c9xxxx
```
Cosign asks:   
```text
Enter password for private key:
```
Enter your password. 

Output:  
```text
Successfully signed
```

## What happened internally?  
Before signing:  
ECR:  
```text
backend:v1.0.0

 |
 |
 v

Image
sha256:8f4a2c9xxxx
```
After signing:  
```text
ECR

backend:v1.0.0

 |
 |
 +---- Image
 |       |
 |       sha256:8f4a2c9xxxx
 |
 |
 +---- Cosign signature
         |
         |
         signed by cosign.key
```
The signature is stored as an OCI artifact in ECR.  

## Step 9: Verify the signature  
Before Kubernetes deployment, test:  
```bash
cosign verify \
--key cosign.pub \
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend@sha256:8f4a2c9xxxx
```
Successful output:  
```text
Verification for
backend@sha256:8f4a2c9xxxx

The following checks were performed:

✓ Signature verified
```

## Step 10: Update Helm values.yaml  
Before:  
```yaml
image:

  repository: 123456789012.dkr.ecr.us-east-1.amazonaws.com/backend

  tag: v1.0.0
```
Problem:  
You are deploying by tag.  
Change to:  
```yaml
image:

  repository: 123456789012.dkr.ecr.us-east-1.amazonaws.com/backend

  digest: sha256:8f4a2c9xxxx
```

## Step 11: Update deployment.yaml Helm template 
Before:  
```yaml
containers:

- name: backend

  image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```
Produces:  
```yaml
image:
 backend:v1.0.0
```
Change to:  
```yaml
containers:

- name: backend

  image: "{{ .Values.image.repository }}@{{ .Values.image.digest }}"
```
Produces:  
```yaml
image:
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend@sha256:8f4a2c9xxxx
```

## Step 12: Commit Helm change  
Git:  
```yaml
git add apps/backend/values.yaml

git commit -m "Deploy backend using immutable image digest"

git push
```

## Step 13: ArgoCD detects change  
Flow:  
```text
GitHub

values.yaml updated

        |
        v

ArgoCD sync

        |
        v

Helm renders

        |
        v

Deployment YAML

image:
backend@sha256:8f4a2c9xxxx

        |
        v

Kubernetes API Server

        |
        v

Kyverno
```

## Step 14: Kyverno verifies  
Kyverno sees:  
```yaml
image:
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend@sha256:8f4a2c9xxxx
```
Checks:  

**Registry**
```text
Is it ECR?
```
✅ Yes

Allow:  
```text
Pod Created
```

## How GitHub Actions does this in real companies  
Usually the developer does NOT manually run these commands.

Pipeline:  
```text
GitHub Actions

1. Build image

2. Push image to ECR

3. Get digest

4. Cosign sign digest

5. Update Helm values.yaml

6. Commit back to Git repo

7. ArgoCD deploys

8. Kyverno verifies
```



















