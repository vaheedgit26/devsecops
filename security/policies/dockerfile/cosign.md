## Key Based Signing  
1. Sign the Image
```bash
cosign sign \
--key cosign.key \
123456789.dkr.ecr.us-east-1.amazonaws.com/backend@sha256:xxxx
```
2. Generate SBOM
```bash
trivy image \
--format cyclonedx \
-o sbom.json \
$IMAGE
```
3. SBOM Attestation
```bash
cosign attest \
--key cosign.key \
--predicate sbom.json \
--type cyclonedx \
$IMAGE
```
## ✅ 1. GitHub Actions — KEY-BASED SIGNING + SBOM   
**🔐 Required GitHub Secrets**    
```bash
COSIGN_PRIVATE_KEY   → contents of cosign.key
COSIGN_PASSWORD      → password (if used)
```
**🔹 Workflow Snippet**  
```bash
name: Key-Based Signing Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  build-sign:
    runs-on: ubuntu-latest

    env:
      AWS_REGION: us-east-1
      ECR_REPO: your-account-id.dkr.ecr.us-east-1.amazonaws.com/app

    steps:

    - name: Checkout
      uses: actions/checkout@v4

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

    - name: Install Cosign
      uses: sigstore/cosign-installer@v3

    - name: Install Trivy
      run: |
        sudo apt-get install -y wget
        wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.1_Linux-64bit.deb
        sudo dpkg -i trivy_0.50.1_Linux-64bit.deb

    # 🔹 Build
    - name: Build Image
      run: |
        docker build -t $ECR_REPO:${{ github.sha }} .

    # 🔹 Push
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

        IMAGE_URI="$ECR_REPO@$DIGEST"

        echo "DIGEST=$DIGEST" >> $GITHUB_ENV
        echo "IMAGE_URI=$IMAGE_URI" >> $GITHUB_ENV

    # 🔐 Load cosign key
    - name: Setup Cosign Key
      run: |
        echo "${{ secrets.COSIGN_PRIVATE_KEY }}" > cosign.key

    # 🔹 IMAGE SIGNING (digest-based ✅)
    - name: Sign Image (Key-Based)
      run: |
        cosign sign --yes \
          --key cosign.key \
          $IMAGE_URI

    # 🔹 SBOM GENERATION (uses same digest ✅)
    - name: Generate SBOM (CycloneDX)
      run: |
        trivy image \
          --format cyclonedx \
          -o sbom.json \
          $IMAGE_URI

    # 🔹 SBOM ATTESTATION (digest-based ✅)
    - name: Attach SBOM (Key-Based)
      run: |
        cosign attest \
          --yes \
          --key cosign.key \
          --predicate sbom.json \
          --type cyclonedx \
          $IMAGE_URI
```















