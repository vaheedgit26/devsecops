```text
repo/
│
├── apps/
│   |
│   └── backend/
│       |
│       ├── Chart.yaml
│       ├── values.yaml
│       |
│       └── templates/
│           |
│           ├── deployment.yaml
│           ├── service.yaml
│           └── ingress.yaml
│
├── security/
│   |
│   └── policies/
│       |
│       └── kubernetes/
│           |
│           ├── image.rego
│           ├── security-context.rego
│           └── resources.rego
│
└── .github/
    |
    └── workflows/
        |
        └── security.yaml
```
