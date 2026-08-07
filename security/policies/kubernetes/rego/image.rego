# This checks Deployment main container image must come from ECR only 
package kubernetes.security

#################################################
# Allowed ECR Registry
#################################################

allowed_registry := "123456789012.dkr.ecr.us-east-1.amazonaws.com"

#allowed_registries := [
#    "123456789012.dkr.ecr.us-east-1.amazonaws.com",
#    "docker.io"
#]

#################################################
# Check only Deployment resources
#################################################

deny[msg] {
    input.kind == "Deployment"
    image := input.spec.template.spec.containers[0].image
    not startswith(image, allowed_registry)
    msg := sprintf(
        "Deployment '%s' main container image '%s' must come from ECR registry '%s'",
        [
            input.metadata.name,
            image,
            allowed_registry
        ]
    )
}
