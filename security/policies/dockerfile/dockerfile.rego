package dockerfile.security

# ------------------------------
# Helper functions
# ------------------------------

cmd(i) = c {
  c := lower(input[i].Cmd)
}

val(i) = v {
  v := lower(concat(" ", input[i].Value))
}

# ------------------------------
# 1. Require explicit image tag or digest
# ------------------------------

deny[msg] {
  cmd(i) == "from"
  image := input[i].Value[0]

  not contains(image, ":")
  not contains(image, "@sha256:")

  msg := sprintf("Line %d: Base image must have explicit tag or digest: %s", [i, image])
}

# ------------------------------
# 2. Block latest tag
# ------------------------------

deny[msg] {
  cmd(i) == "from"
  image := lower(input[i].Value[0])

  contains(image, ":latest")

  msg := sprintf("Line %d: Avoid using latest tag: %s", [i, image])
}

# ------------------------------
# 3. Require USER (no implicit root)
# ------------------------------

deny[msg] {
  not any_user_defined
  msg := "No USER specified. Container runs as root by default"
}

any_user_defined {
  some i
  cmd(i) == "user"
}

# ---------------------------------
# 4. Prevent root user explicitly
# ---------------------------------

deny[msg] {
  cmd(i) == "user"
  user := lower(input[i].Value[0])

  user == "root" 
  or user == "0"
  or startswith(user, "0:")

  msg := sprintf("Line %d: Avoid running as root user", [i])
}

# ---------------------------------
# 5. Prevent curl | bash
# ---------------------------------

deny[msg] {
  cmd(i) == "run"
  line := val(i)

  contains(line, "curl")
  contains(line, "|")
  contains(line, "bash")

  msg := sprintf("Line %d: Avoid curl | bash pattern", [i])
}

# ---------------------------------
# 6. Avoid ADD
# ---------------------------------

deny[msg] {
  cmd(i) == "add"
  msg := sprintf("Line %d: Use COPY instead of ADD", [i])
}

# ---------------------------------
# 7. Avoid sudo
# ---------------------------------

deny[msg] {
  cmd(i) == "run"
  contains(val(i), "sudo")

  msg := sprintf("Line %d: Avoid using sudo", [i])
}

# ----------------------------------
# 8. Apt hygiene (cleanup)
# ----------------------------------

deny[msg] {
  cmd(i) == "run"
  line := val(i)

  contains(line, "apt-get install")
  not contains(line, "rm -rf /var/lib/apt/lists")

  msg := sprintf("Line %d: Clean apt cache after install", [i])
}

# -------------------------------------------
# 9. Avoid apt upgrade
# -------------------------------------------

deny[msg] {
  cmd(i) == "run"
  contains(val(i), "apt-get upgrade")

  msg := sprintf("Line %d: Avoid apt-get upgrade", [i])
}

# ----------------------------------
# 10. Ensure WORKDIR exists
# ----------------------------------

warn[msg] {
  not workdir_defined
  msg := "WORKDIR is not defined"
}

workdir_defined {
  some i
  cmd(i) == "workdir"
}

# ----------------------------------
# 11. Avoid cd
# ----------------------------------

deny[msg] {
  cmd(i) == "run"
  contains(val(i), "cd ")

  msg := sprintf("Line %d: Use WORKDIR instead of cd", [i])
}

# ----------------------------------
# 12. Multi-stage recommendation
# ----------------------------------

warn[msg] {
  count(froms) < 2
  msg := "Consider using multi-stage builds"
}

froms[i] {
  cmd(i) == "from"
}

# ----------------------------------
# 13. Detect secrets in ENV
# ----------------------------------

deny[msg] {
  cmd(i) == "env"
  re_match("(?i)(password|passwd|secret|token|api[_-]?key|access[_-]?key|auth|credential)", val(i))

  msg := sprintf("Line %d: Possible secret in ENV", [i])
}
