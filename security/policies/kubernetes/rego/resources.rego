package kubernetes.security

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.cpu
    msg := sprintf(
        "Deployment %s container %s must define CPU request",
        [
          input.metadata.name,
          container.name
        ]
    )
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.memory
    msg := sprintf(
        "Deployment %s container %s must define memory request",
        [
          input.metadata.name,
          container.name
        ]
    )
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.cpu
    msg := sprintf(
        "Deployment %s container %s must define CPU limit",
        [
          input.metadata.name,
          container.name
        ]
    )
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    msg := sprintf(
        "Deployment %s container %s must define memory limit",
        [
          input.metadata.name,
          container.name
        ]
    )
}
