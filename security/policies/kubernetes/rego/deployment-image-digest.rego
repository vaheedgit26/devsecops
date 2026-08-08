# This checks Deployment main container image should contain image DIGEST not tags

package kubernetes.security

# --------------------------------------------------
# DENY if main container image does NOT use digest
# --------------------------------------------------

deny[msg] {
  input.kind == "Deployment"

  container := input.spec.template.spec.containers[0]
  image := container.image

  not has_digest(image)

  msg := sprintf(
    "Deployment %s main container %s image '%s' must use a digest (@sha256:...)",
    [
      input.metadata.name,
      container.name,
      image
    ]
  )
}

# --------------------------------------------------
# Helper: check if image has sha256 digest
# --------------------------------------------------

has_digest(image) {
  re_match(".*@sha256:[a-f0-9]{64}$", image)
}
