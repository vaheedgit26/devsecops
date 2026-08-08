# This checks Deployment main container image must come from ECR only 
package kubernetes.security

# --------------------------------------------------
# Allowed registries (EDIT THIS LIST)
# --------------------------------------------------
allowed_registries := [
  "123456789012.dkr.ecr.us-east-1.amazonaws.com",
  "123456789012.dkr.ecr.eu-west-1.amazonaws.com"
]

# --------------------------------------------------
# Helper: check if image starts with any allowed registry
# --------------------------------------------------
is_allowed_registry(image) {
  some i
  startswith(image, allowed_registries[i])
}

# --------------------------------------------------
# DENY if main container image is NOT from allowed registries
# --------------------------------------------------
deny[msg] {
  input.kind == "Deployment"

  container := input.spec.template.spec.containers[0]
  image := container.image

  not is_allowed_registry(image)

  msg := sprintf(
    "Deployment %s main container %s image '%s' must come from allowed registries: %v",
    [
      input.metadata.name,
      container.name,
      image,
      allowed_registries
    ]
  )
}
