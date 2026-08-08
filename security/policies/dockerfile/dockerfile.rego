package dockerfile.security

# ==========================================================
# Helper functions
# ==========================================================

cmd(i) = c {
    c := lower(input[i].Cmd)
}

val(i) = v {
    v := lower(concat(" ", input[i].Value))
}


# ==========================================================
# 1. BASE IMAGE MUST HAVE TAG OR DIGEST
# ==========================================================

deny[msg] {
    cmd(i) == "from"

    image := input[i].Value[0]

    not contains(image, ":")
    not contains(image, "@sha256:")

    msg := sprintf(
        "Line %d: Base image must have an explicit tag or digest: %s",
        [i, image]
    )
}


# ==========================================================
# 2. BLOCK latest TAG
# ==========================================================

deny[msg] {
    cmd(i) == "from"

    image := lower(input[i].Value[0])

    contains(image, ":latest")

    msg := sprintf(
        "Line %d: Avoid using latest tag: %s",
        [i, image]
    )
}


# ==========================================================
# 3. USER MUST BE DEFINED
# ==========================================================

deny[msg] {
    not any_user_defined

    msg := "No USER specified. Container runs as root by default"
}

any_user_defined {
    some i

    cmd(i) == "user"
}


# ==========================================================
# 4. PREVENT EXPLICIT ROOT USER
# ==========================================================

deny[msg] {
    cmd(i) == "user"

    user := lower(input[i].Value[0])

    user == "root"
    or user == "0"
    or startswith(user, "0:")

    msg := sprintf(
        "Line %d: Avoid running as root user: %s",
        [i, user]
    )
}


# ==========================================================
# 5. BLOCK curl | bash
# ==========================================================

deny[msg] {
    cmd(i) == "run"

    line := val(i)

    contains(line, "curl")
    contains(line, "|")
    contains(line, "bash")

    msg := sprintf(
        "Line %d: Avoid curl | bash pattern",
        [i]
    )
}


# ==========================================================
# 6. AVOID ADD
# ==========================================================

deny[msg] {
    cmd(i) == "add"

    msg := sprintf(
        "Line %d: Use COPY instead of ADD",
        [i]
    )
}


# ==========================================================
# 7. AVOID sudo
# ==========================================================

deny[msg] {
    cmd(i) == "run"

    contains(val(i), "sudo")

    msg := sprintf(
        "Line %d: Avoid using sudo in containers",
        [i]
    )
}


# ==========================================================
# 8. APT CACHE MUST BE CLEANED
# ==========================================================

deny[msg] {
    cmd(i) == "run"

    line := val(i)

    contains(line, "apt-get install")
    not contains(line, "rm -rf /var/lib/apt/lists")

    msg := sprintf(
        "Line %d: Clean apt cache after package installation",
        [i]
    )
}


# ==========================================================
# 9. AVOID apt-get upgrade
# ==========================================================

deny[msg] {
    cmd(i) == "run"

    contains(val(i), "apt-get upgrade")

    msg := sprintf(
        "Line %d: Avoid apt-get upgrade because it reduces build reproducibility",
        [i]
    )
}


# ==========================================================
# 10. WORKDIR SHOULD EXIST
# ==========================================================

warn[msg] {
    not workdir_defined

    msg := "WORKDIR is not defined"
}

workdir_defined {
    some i

    cmd(i) == "workdir"
}


# ==========================================================
# 11. AVOID cd
# ==========================================================

deny[msg] {
    cmd(i) == "run"

    contains(val(i), "cd ")

    msg := sprintf(
        "Line %d: Use WORKDIR instead of cd",
        [i]
    )
}


# ==========================================================
# 12. MULTI-STAGE BUILD RECOMMENDATION
# ==========================================================

warn[msg] {
    count(froms) < 2

    msg := "Consider using a multi-stage Docker build to reduce image size"
}

froms[i] {
    cmd(i) == "from"
}


# ==========================================================
# 13. DETECT POSSIBLE SECRETS IN ENV
# ==========================================================

deny[msg] {
    cmd(i) == "env"

    re_match(
        "(?i)(password|passwd|secret|token|api[_-]?key|access[_-]?key|auth|credential)",
        val(i)
    )

    msg := sprintf(
        "Line %d: Possible secret detected in ENV instruction",
        [i]
    )
}
