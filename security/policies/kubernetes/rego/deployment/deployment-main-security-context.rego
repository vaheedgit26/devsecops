package kubernetes.security

# ==========================================================
# Enterprise Security Context Policy
#
# Applies to:
#   Deployment
#
# Checks ONLY:
#   spec.template.spec.containers[0]
#
# Requirements:
#   1. securityContext must exist
#   2. runAsUser > 0
#   3. runAsGroup > 0
#   4. runAsNonRoot == true
#   5. readOnlyRootFilesystem == true
#   6. allowPrivilegeEscalation == false
#   7. capabilities.drop must contain ALL
# ==========================================================

# ==========================================================
# Helper
#
# Return the main application container.
# ==========================================================

main_container := input.spec.template.spec.containers[0]

# ==========================================================
# 1. SECURITY CONTEXT MUST EXIST
# ==========================================================

deny[msg] {
    input.kind == "Deployment"
    not main_container.securityContext

    msg := sprintf(
        "Deployment %s main container %s must define a container-level securityContext",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

# ==========================================================
# 2. runAsUser MUST EXIST AND BE > 0
# ==========================================================

deny[msg] {
    input.kind == "Deployment"
    not main_container.securityContext.runAsUser

    msg := sprintf(
        "Deployment %s main container %s must define securityContext.runAsUser greater than 0",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

deny[msg] {
    input.kind == "Deployment"
    user := main_container.securityContext.runAsUser
    user <= 0

    msg := sprintf(
        "Deployment %s main container %s runAsUser must be greater than 0, but found %v",
        [
            input.metadata.name,
            main_container.name,
            user
        ]
    )
}

# ==========================================================
# 3. runAsGroup MUST EXIST AND BE > 0
# ==========================================================

deny[msg] {
    input.kind == "Deployment"
    not main_container.securityContext.runAsGroup

    msg := sprintf(
        "Deployment %s main container %s must define securityContext.runAsGroup greater than 0",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

deny[msg] {
    input.kind == "Deployment"
    group := main_container.securityContext.runAsGroup
    group <= 0

    msg := sprintf(
        "Deployment %s main container %s runAsGroup must be greater than 0, but found %v",
        [
            input.metadata.name,
            main_container.name,
            group
        ]
    )
}

# ==========================================================
# 4. runAsNonRoot MUST BE TRUE
# ==========================================================

deny[msg] {
    input.kind == "Deployment"
    not main_container.securityContext.runAsNonRoot

    msg := sprintf(
        "Deployment %s main container %s securityContext.runAsNonRoot must be true",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

deny[msg] {
    input.kind == "Deployment"
    main_container.securityContext.runAsNonRoot != true

    msg := sprintf(
        "Deployment %s main container %s securityContext.runAsNonRoot must be true",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

# ==========================================================
# 5. readOnlyRootFilesystem MUST BE TRUE
# ==========================================================

deny[msg] {
    input.kind == "Deployment"
    not main_container.securityContext.readOnlyRootFilesystem

    msg := sprintf(
        "Deployment %s main container %s securityContext.readOnlyRootFilesystem must be true",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

deny[msg] {
    input.kind == "Deployment"
    main_container.securityContext.readOnlyRootFilesystem != true

    msg := sprintf(
        "Deployment %s main container %s securityContext.readOnlyRootFilesystem must be true",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

# ==========================================================
# 6. allowPrivilegeEscalation MUST BE FALSE
# ==========================================================

deny[msg] {
    input.kind == "Deployment"
    not main_container.securityContext.allowPrivilegeEscalation

    msg := sprintf(
        "Deployment %s main container %s securityContext.allowPrivilegeEscalation must be explicitly set to false",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

deny[msg] {
    input.kind == "Deployment"
    main_container.securityContext.allowPrivilegeEscalation != false

    msg := sprintf(
        "Deployment %s main container %s securityContext.allowPrivilegeEscalation must be false",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

# ==========================================================
# 7. capabilities MUST EXIST
# ==========================================================

deny[msg] {
    input.kind == "Deployment"
    not main_container.securityContext.capabilities

    msg := sprintf(
        "Deployment %s main container %s must define securityContext.capabilities",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

# ==========================================================
# 8. capabilities.drop MUST EXIST
# ==========================================================

deny[msg] {
    input.kind == "Deployment"
    not main_container.securityContext.capabilities.drop

    msg := sprintf(
        "Deployment %s main container %s must define securityContext.capabilities.drop",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

# ==========================================================
# 9. capabilities.drop MUST CONTAIN ALL
# ==========================================================

deny[msg] {
    input.kind == "Deployment"
    drop := main_container.securityContext.capabilities.drop
    not contains(drop, "ALL")

    msg := sprintf(
        "Deployment %s main container %s securityContext.capabilities.drop must contain ALL",
        [
            input.metadata.name,
            main_container.name
        ]
    )
}

# ==========================================================
# Helper: Check whether an array contains a value
# ==========================================================

contains(array, value) {
    some i
    array[i] == value
}
```
