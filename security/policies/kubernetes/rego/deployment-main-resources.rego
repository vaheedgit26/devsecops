package kubernetes.security

# ============================================================
# Deployment main container must define:
#   1. CPU request
#   2. Memory request
#   3. CPU limit
#   4. Memory limit
#
# Main container = spec.template.spec.containers[0]
# ============================================================

# Deny if CPU request is not defined
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    not container.resources.requests.cpu

    msg := sprintf(
        "Deployment %s main container %s must define CPU request",
        [
            input.metadata.name,
            container.name
        ]
    )
}

# Deny if MEMORY request is not defined
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    not container.resources.requests.memory

    msg := sprintf(
        "Deployment %s main container %s must define memory request",
        [
            input.metadata.name,
            container.name
        ]
    )
}

# Deny if CPU limits is not defined
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    not container.resources.limits.cpu

    msg := sprintf(
        "Deployment %s main container %s must define CPU limit",
        [
            input.metadata.name,
            container.name
        ]
    )
}

# Deny if MEMORY limits is not defined
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    not container.resources.limits.memory

    msg := sprintf(
        "Deployment %s main container %s must define memory limit",
        [
            input.metadata.name,
            container.name
        ]
    )
}
