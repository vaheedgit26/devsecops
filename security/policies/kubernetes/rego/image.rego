package kubernetes.security

deny[msg] {
    container := input.spec.template.spec.containers[_]
    not allowed_image(container.image)
    msg := sprintf(
        "Image '%s' is not from approved registry",
        [container.image]
    )
}

allowed_image(image) {
    registry := data.allowed_registries[_]
    startswith(image, registry)
}
