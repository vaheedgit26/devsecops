## 1. Create a cosign key pair  
```bash
cosign generate-key-pair
```
**You get:**  
```text
cosign.key
cosign.pub
```
**keep:**
```text
cosign.key
```

**in GitHub Secrets.**  

**Example:**  
```text
COSIGN_PRIVATE_KEY
```
**Keep:**  
```text
cosign.pub
```

## 2. Sign your ECR image  
**Your image:**  
```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/backend:v1.0.5
```

**After Push:**   





