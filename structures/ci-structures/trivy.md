```text
                 Trivy
                   │
          ┌────────┴─────────┐
          │                  │
       trivy fs           trivy image
          │                  │
          ▼                  ▼
     Source code         Container
     repository             image
          │                  │
          ▼                  ▼
   Dependencies          OS packages
   Secrets               App packages
   IaC/config            Image contents
```
