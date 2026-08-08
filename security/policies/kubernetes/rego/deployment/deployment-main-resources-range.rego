
package kubernetes.security
import data.kubernetes.quantity

# ============================================================
# Deployment main container resource policy
#
# Main container = spec.template.spec.containers[0]
#
# CPU REQUEST:
#   Required
#   Minimum: 50m
#   Maximum: 500m
#
# MEMORY REQUEST:
#   Required
#   Minimum: 64Mi
#   Maximum: 512Mi
#
# CPU LIMIT:
#   Required
#   Maximum: 500m
#
# MEMORY LIMIT:
#   Required
#   Maximum: 512Mi
# ============================================================


# ============================================================
# CPU REQUEST - REQUIRED
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    not container.resources.requests.cpu

    msg := sprintf(
        "Deployment %s main container %s must define a CPU request",
        [
            input.metadata.name,
            container.name
        ]
    )
}

# ============================================================
# CPU REQUEST - MINIMUM 50m
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    cpu := container.resources.requests.cpu
    cpu_value := quantity.parse(cpu)
    cpu_value < quantity.parse("50m")

    msg := sprintf(
        "Deployment %s main container %s CPU request %s is below minimum 50m",
        [
            input.metadata.name,
            container.name,
            cpu
        ]
    )
}

# ============================================================
# CPU REQUEST - MAXIMUM 500m
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    cpu := container.resources.requests.cpu
    cpu_value := quantity.parse(cpu)
    cpu_value > quantity.parse("500m")

    msg := sprintf(
        "Deployment %s main container %s CPU request %s exceeds maximum 500m",
        [
            input.metadata.name,
            container.name,
            cpu
        ]
    )
}

# ============================================================
# MEMORY REQUEST - REQUIRED
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    not container.resources.requests.memory

    msg := sprintf(
        "Deployment %s main container %s must define a memory request",
        [
            input.metadata.name,
            container.name
        ]
    )
}

# ============================================================
# MEMORY REQUEST - MINIMUM 64Mi
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    memory := container.resources.requests.memory
    memory_value := quantity.parse(memory)
    memory_value < quantity.parse("64Mi")

    msg := sprintf(
        "Deployment %s main container %s memory request %s is below minimum 64Mi",
        [
            input.metadata.name,
            container.name,
            memory
        ]
    )
}

# ============================================================
# MEMORY REQUEST - MAXIMUM 512Mi
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    memory := container.resources.requests.memory
    memory_value := quantity.parse(memory)
    memory_value > quantity.parse("512Mi")

    msg := sprintf(
        "Deployment %s main container %s memory request %s exceeds maximum 512Mi",
        [
            input.metadata.name,
            container.name,
            memory
        ]
    )
}

# ============================================================
# CPU LIMIT - REQUIRED
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    not container.resources.limits.cpu

    msg := sprintf(
        "Deployment %s main container %s must define a CPU limit",
        [
            input.metadata.name,
            container.name
        ]
    )
}

# ============================================================
# CPU LIMIT - MAXIMUM 500m
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    cpu := container.resources.limits.cpu
    cpu_value := quantity.parse(cpu)
    cpu_value > quantity.parse("500m")

    msg := sprintf(
        "Deployment %s main container %s CPU limit %s exceeds maximum 500m",
        [
            input.metadata.name,
            container.name,
            cpu
        ]
    )
}

# ============================================================
# MEMORY LIMIT - REQUIRED
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    not container.resources.limits.memory

    msg := sprintf(
        "Deployment %s main container %s must define a memory limit",
        [
            input.metadata.name,
            container.name
        ]
    )
}

# ============================================================
# MEMORY LIMIT - MAXIMUM 512Mi
# ============================================================

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    memory := container.resources.limits.memory
    memory_value := quantity.parse(memory)
    memory_value > quantity.parse("512Mi")

    msg := sprintf(
        "Deployment %s main container %s memory limit %s exceeds maximum 512Mi",
        [
            input.metadata.name,
            container.name,
            memory
        ]
    )
}
