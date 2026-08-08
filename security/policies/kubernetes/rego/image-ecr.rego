# This checks Deployment main container image must come from ECR only 
package kubernetes.security

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[0]
    image := container.image

    # Regex match for full ECR format
    not re_match("^123456789012\\.dkr\\.ecr\\.[a-z0-9-]+\\.amazonaws\\.com/.+", image)

    msg := sprintf(
        "Deployment %s main container %s image '%s' must come from ECR",
        [
            input.metadata.name,
            container.name,
            image
        ]
    )
}
