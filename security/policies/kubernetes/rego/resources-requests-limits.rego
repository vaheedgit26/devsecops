# CPU:     Minimum: 50m   Maximum: 500m
# MEMORY:  Minimum: 64Mi  Maximum: 512Mi

package kubernetes.security
import data.kubernetes.quantity
#################################################
# Main container CPU request validation
#################################################

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

#################################################
# Main container Memory request validation
#################################################

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
