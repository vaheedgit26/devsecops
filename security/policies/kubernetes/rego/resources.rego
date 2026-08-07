# Enforces Deployment main container must have resource requests and limits
package kubernetes.security
#################################################
# Main container must define resources
#################################################

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    not container.resources
    msg := sprintf(
        "Deployment %s main container %s must define resources",
        [
            input.metadata.name,
            container.name
        ]
    )
}

#################################################
# CPU request required
#################################################

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

#################################################
# Memory request required
#################################################

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

#################################################
# CPU limit required
#################################################

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

#################################################
# Memory limit required
#################################################

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
