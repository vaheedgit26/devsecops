# This checks Deployment main container image should contain image DIGEST not tags
package kubernetes.security
#################################################
# Deployment image must use digest
#################################################

deny[msg] {
    input.kind == "Deployment"
    image := input.spec.template.spec.containers[0].image
    not contains(image, "@sha256:")
    msg := sprintf(
        "Deployment '%s' main container image '%s' must use image digest (@sha256:) instead of tag",
        [
            input.metadata.name,
            image
        ]
    )
}
