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
IMAGE
```
3. SBOM Attestation
```bash
cosign attest \
--key cosign.key \
--predicate sbom.json \
--type cyclonedx \
IMAGE
```
