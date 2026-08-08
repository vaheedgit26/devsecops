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

`**latest**`
```dockerfile
FROM ubuntu:latest
```

It can recommend avoiding floating tags.  

**`apt-get` issues**  
 
For example:  
```dockerfile
RUN apt-get update  
RUN apt-get install -y curl  
```
Hadolint can identify package-management problems and recommend better practices.  


















