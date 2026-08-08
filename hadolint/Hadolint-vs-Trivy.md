# Hadolint vs Trivy  
> **Hadolint is a Dockerfile linter. Trivy is primarily a security/misconfiguration scanner that can also inspect Dockerfiles.**
 
They overlap a little, but they are not substitutes.

## 1. High-level difference  
| Area                         | Hadolint                                 | Trivy Dockerfile scan                           |  
| ---------------------------- | ---------------------------------------- | ----------------------------------------------- |  
| Primary purpose              | Dockerfile best-practice linting         | Security/misconfiguration scanning              |  
| Dockerfile syntax/style      | ⭐⭐⭐⭐⭐                                    | ⭐⭐                                              |  
| Shell command quality        | ⭐⭐⭐⭐⭐                                    | ⭐                                               |  
| Docker best practices        | ⭐⭐⭐⭐⭐                                    | ⭐⭐⭐                                             |  
| Security misconfigurations   | ⭐⭐⭐                                      | ⭐⭐⭐⭐⭐                                           |  
| Vulnerability scanning       | ❌                                        | ❌*                                              |  
| Secrets in Dockerfile        | Limited                                  | Better security-oriented detection              |  
| Base image security          | Limited                                  | ⭐⭐⭐⭐                                            |  
| `USER` / root checks         | ✅                                        | ✅                                               |  
| `ADD` vs `COPY`              | ✅                                        | May detect related issues                       |  
| `apt-get` hygiene            | ✅                                        | Some checks                                     |  
| `apt-get upgrade`            | ✅                                        | May detect related issues                       |  
| Organization-specific rules  | Via plugins/config, but not its strength | Better combined with Rego/Conftest              |  
| Image vulnerability scanning | ❌                                        | ✅, but **after build**                          |  
| SBOM                         | ❌                                        | ✅                                               |  
| Best use                     | Dockerfile quality                       | Dockerfile security + broader security scanning |  

> A **Dockerfile** itself doesn't contain the complete package inventory of the final image, so vulnerability scanning should be done against the **built image**.

## 2. What Hadolint does

Hadolint is basically:

> **"Is this Dockerfile written correctly and following Docker best practices?"**

For example:  

```dockerfile
FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y curl

ADD app /app

RUN cd /app && ./build.sh

USER root
```

Hadolint can flag things such as:

**`latest`**
```dockerfile
FROM ubuntu:latest
```

It can recommend avoiding floating tags.  

**`apt-get`** **issues**  
 
For example:  
```dockerfile
RUN apt-get update  
RUN apt-get install -y curl  
```
Hadolint can identify package-management problems and recommend better practices.  

**`ADD`**  
```dockerfile
ADD app.tar /app/
```
Hadolint can recommend:  
```dockerfile
COPY app.tar /app/
```
when `ADD` functionality isn't needed.  

**Multiple `RUN` layers**

It can identify Dockerfile construction issues.

**`Shell`** **issues**  

For example:  
```dockerfile
RUN echo $PASSWORD  
```
or shell constructs that are likely to behave unexpectedly.    

**`sudo`**
```dockerfile
RUN sudo apt-get install ...
```
Hadolint can flag this as unnecessary inside a container.  

**`USER`**

Hadolint has rules related to running containers as non-root.  


## 3. What Trivy Dockerfile scanning does  

Trivy approaches the Dockerfile from a different perspective:  

> **"Does this Dockerfile contain security-relevant misconfigurations?"**

For example:  
```dockerfile
FROM ubuntu:22.04  

USER root  

ENV AWS_SECRET_ACCESS_KEY=abc123  

EXPOSE 22  

RUN chmod 777 /app  
```

Trivy's configuration scanner can identify security-related configuration issues depending on the rules/checks available in the installed Trivy version.  

Trivy is much more focused on:  
```text
Security
   ↓
Misconfiguration
   ↓
Risk

rather than general Dockerfile quality.
```

## 4. The biggest difference: linting vs security  

Think about this:  
```dockerfile
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*
```
Hadolint is very good at saying:  

> "This Dockerfile follows/doesn't follow Dockerfile best practices."  

Trivy is more interested in:  

"Does this Dockerfile introduce a security risk?"  

So:  
```text
Hadolint
    ↓
Quality / correctness / best practices

Trivy
    ↓
Security / misconfiguration
```

## 5. What about vulnerabilities?  

This is extremely important.  

Suppose you have:  
```dockerfile
FROM python:3.11
COPY app.py /app/
```
Neither Hadolint nor a Dockerfile-only Trivy scan can reliably tell you:  
```text
OpenSSL
CRITICAL
CVE-XXXX-XXXX
```
because the actual installed packages are determined when the image is built.  

Therefore:  
```text
Dockerfile
    │
    ▼
Hadolint
    │
    ▼
Trivy config scan
    │
    ▼
docker build
    │
    ▼
Built image
    │
    ▼
Trivy image scan
```
The **image scan** is where you should perform vulnerability scanning.  

Example:  
```bash
trivy image \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  my-app:1.0
```

## 6. Example showing the difference  

Consider:  
```dockerfile
FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y curl

ADD . /app

ENV DB_PASSWORD=MyPassword123

USER root

CMD ["python", "/app/app.py"]
```
**Hadolint may care about**  
```text
❌ apt-get usage/hygiene  
❌ ADD instead of COPY  
❌ USER/root related best practice  
❌ Dockerfile construction
```
**Trivy may care about**  
```text
❌ Security-sensitive configuration
❌ Potential secret exposure
❌ Running as root
❌ Other security misconfigurations
```
**Trivy image scan later cares about**  
```text
❌ CVE-XXXX
❌ CVE-YYYY
❌ vulnerable OS packages
❌ vulnerable application dependencies
```

That's why the tools complement each other.  


## 7. Should you use both?  

For an enterprise pipeline: **yes, I would.**  

Your pipeline can be:  
```text
                    Dockerfile
                        │
              ┌─────────┴─────────┐
              │                   │
              ▼                   ▼
          Hadolint             Trivy config
              │                   │
              │              Security scan
              │                   │
              └─────────┬─────────┘
                        │
                        ▼
                  OPA/Conftest
                        │
                Organization rules
                        │
                        ▼
                   Docker Build
                        │
                        ▼
                 Trivy Image Scan
                        │
                        ▼
                    Push ECR
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
```

## 8. Where your custom Rego fits  

This is especially relevant to the Rego policies you've been writing.  

Don't try to make Hadolint replace your Rego.  

For example, suppose your company says:  

> Every base image must come from these approved registries.

```rego
allowed_registries := [
    "123456789012.dkr.ecr.us-east-1.amazonaws.com",
    "123456789012.dkr.ecr.eu-west-1.amazonaws.com"
]
```
That's an **organization-specific policy.**  

Hadolint isn't designed for that.  
Your architecture should therefore be:  
```text
Hadolint
    ↓
Generic Dockerfile best practices

Trivy
    ↓
Security misconfigurations

OPA/Conftest
    ↓
Your organization's custom rules
```

## 9. When should each be used?  
**Use Hadolint when you want:**    
> **"Is my Dockerfile well-written?"**    

Examples:   

- Dockerfile best practices  
- shell quality  
- RUN construction  
- apt hygiene  
- ADD vs COPY  
- Dockerfile maintainability  
- linting

**Use Trivy when you want:**  

> **"Is my Dockerfile/image introducing security risks?"**  

Examples:  

- Dockerfile security misconfiguration  
- secrets/security issues  
- configuration problems  
- image vulnerabilities  
- OS package vulnerabilities  
- application dependency vulnerabilities  
- SBOM

**Use OPA/Conftest when you want:**  
```text
"Does this comply with OUR organization's rules?"  
```
Examples:  
```text
Only approved base images
Only approved registries
Required image version
Required labels
Prohibited packages
Organization-specific security requirements
```

## 10. My recommendation for your setup  

Since you're building an **EKS + DevSecOps + Cosign + Kyverno** architecture, I'd use:  
```text

                    PRE-BUILD
                       │
             ┌─────────┼─────────┐
             │         │         │
             ▼         ▼         ▼
         Hadolint    Trivy    Conftest
         Dockerfile  Config    OPA/Rego
             │         │         │
             └─────────┼─────────┘
                       │
                    PASS
                       │
                       ▼
                  Docker Build
                       │
                       ▼
                    Trivy
                  Image Scan
                       │
                       ├── Vulnerabilities
                       └── SBOM
                       │
                       ▼
                    Push ECR
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
             ┌─────────┼─────────┐
             ▼         ▼         ▼
          ECR-only   Digest    Signature
          Image      required  verified
```
          
In short:  

> **Hadolint = Dockerfile quality**  
> **Trivy = security**  
> **OPA/Conftest = organization policy**  
> **Cosign = supply-chain identity/integrity**  
> **Kyverno = Kubernetes admission enforcement**  


That division of responsibility is cleaner and much easier to maintain than trying to make Trivy, Hadolint, or Rego do everything.  
