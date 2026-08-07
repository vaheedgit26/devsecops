## Key less signing  
1. Sign the image
```bash
cosign sign --yes $IMAGE_WITH_DIGEST
```
2. Generate SBOM
```bash
trivy image \
  --format cyclonedx \
  --output sbom.json \
  $IMAGE_WITH_DIGEST
```
3. SBOM Attestation
```bash
cosign attest \
  --yes \
  --predicate sbom.json \
  --type cyclonedx \
  $IMAGE_WITH_DIGEST
```
## 🔵 GitHub Actions — KEYLESS SIGNING + SBOM  
**🔐 Required Permission (IMPORTANT)**  
```yaml
permissions:
  id-token: write
  contents: read
```
**🔹 Workflow Snippet**  
```bash
name: Keyless Signing Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  build-sign:

    runs-on: ubuntu-latest
    env:
      AWS_REGION: us-east-1
      ECR_REPO: your-account-id.dkr.ecr.us-east-1.amazonaws.com/app

    permissions:
      id-token: write
      contents: read

    steps:

    - name: Checkout
      uses: actions/checkout@v4

    - name: Install Cosign
      uses: sigstore/cosign-installer@v3

    - name: Install Trivy
      run: |
        sudo apt-get update
        sudo apt-get install -y wget
        wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.1_Linux-64bit.deb
        sudo dpkg -i trivy_0.50.1_Linux-64bit.deb

    - name: Build Image
      run: |
        docker build -t $ECR_REPO:${{ github.sha }} .

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    #- name: Configure AWS Credentials
    #  uses: aws-actions/configure-aws-credentials@v4
    #  with:
    #    aws-region: ${{ env.AWS_REGION }}
    #    role-to-assume: arn:aws:iam::${{ env.ACCOUNT_ID }}:role/github-actions-role

    - name: Login to ECR
      run: |
        aws ecr get-login-password --region $AWS_REGION \
        | docker login --username AWS --password-stdin $ECR_REPO

    #- name: Login to Amazon ECR
    #  uses: aws-actions/amazon-ecr-login@v2

    - name: Push Image
      run: |
        docker push $ECR_REPO:${{ github.sha }}

    # 🔥 Get DIGEST from ECR (BEST PRACTICE)
    - name: Get Image Digest from ECR
      run: |
        DIGEST=$(aws ecr describe-images \
          --repository-name app \
          --image-ids imageTag=${{ github.sha }} \
          --query 'imageDetails[0].imageDigest' \
          --output text)

        IMAGE_WITH_DIGEST="$ECR_REPO@$DIGEST"

        echo "DIGEST=$DIGEST" >> $GITHUB_ENV
        echo "IMAGE_WITH_DIGEST=$IMAGE_WITH_DIGEST" >> $GITHUB_ENV

    # 🔹 IMAGE SIGNING (KEYLESS)
    - name: Sign Image (Keyless)
      run: |
        cosign sign --yes $IMAGE_WITH_DIGEST

    # 🔹 SBOM GENERATION
    - name: Generate SBOM (CycloneDX)
      run: |
        trivy image \
          --format cyclonedx \
          --output sbom.json \
          $IMAGE_WITH_DIGEST

    # 🔹 SBOM ATTESTATION (KEYLESS)
    - name: Attach SBOM (Keyless)
      run: |
        cosign attest \
          --yes \
          --predicate sbom.json \
          --type cyclonedx \
          $IMAGE_WITH_DIGEST
```
