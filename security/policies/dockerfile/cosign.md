## Key Based Signing  
1. Sign the Image
```bash
1. Sign the Image
cosign sign \
--key cosign.key \
123456789.dkr.ecr.us-east-1.amazonaws.com/backend@sha256:xxxx
```

## SBOM Verification with Key-Based Signing  
```bash
trivy image \
--format cyclonedx \
-o sbom.json \
IMAGE


cosign attest \
--key cosign.key \
--predicate sbom.json \
--type cyclonedx \
IMAGE
```
