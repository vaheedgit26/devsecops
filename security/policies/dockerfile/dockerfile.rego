# ------------------------------
# Helper: normalize command
# ------------------------------
cmd(i) = c {
  c := lower(input[i].Cmd)
}

val(i) = v {
  v := concat(" ", input[i].Value)
}
# ------------------------------
# 1. Block implicit latest
# ------------------------------

deny[msg] {
  cmd(i) == "from"
  image := input[i].Value[0]

  not contains(image, ":")
  msg := sprintf("Line %d: Base image must have explicit tag (implicit latest not allowed): %s", [i, image])
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
# 3. Do not run as root
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
  val(i) == "root"
  msg := sprintf("Line %d: Avoid running as root user", [i])
}

# ---------------------------------
# 5. Prevent curl | bash
# ---------------------------------

deny[msg] {
  cmd(i) == "run"
  line := lower(val(i))

  contains(line, "curl")
  contains(line, "|")
  contains(line, "bash")

  msg := sprintf("Line %d: Avoid curl | bash pattern (supply chain risk)", [i])
}

# ---------------------------------
# 6. Avoid ADD (use COPY)
# ---------------------------------

deny[msg] {
  cmd(i) == "add"
  msg := sprintf("Line %d: Use COPY instead of ADD", [i])
}

# ---------------------------------
# 7. Avoid sudo
#__________________________________

deny[msg] {
  cmd(i) == "run"
  contains(lower(val(i)), "sudo")
  msg := sprintf("Line %d: Avoid using sudo in containers", [i])
}

# ----------------------------------
# 8. Package manager hygiene (apt)
# ----------------------------------

deny[msg] {
  cmd(i) == "run"
  line := lower(val(i))

  contains(line, "apt-get install")
  not contains(line, "rm -rf /var/lib/apt/lists")

  msg := sprintf("Line %d: Clean apt cache to reduce image size", [i])
}

# -------------------------------------------
# 9. Avoid upgrade (breaks reproducibility)
# -------------------------------------------

deny[msg] {
  cmd(i) == "run"
  line := lower(val(i))

  contains(line, "apt-get upgrade")
  msg := sprintf("Line %d: Avoid apt-get upgrade (non-reproducible builds)", [i])
}

# ----------------------------------
# 10. Ensure WORKDIR exists
# ----------------------------------

deny[msg] {
  not workdir_defined
  msg := "WORKDIR is not defined"
}

workdir_defined {
  some i
  cmd(i) == "workdir"
}

# ----------------------------------
# 11. Use WORKDIR instead of cd
# ----------------------------------

deny[msg] {
  cmd(i) == "run"
  contains(lower(val(i)), "cd ")
  msg := sprintf("Line %d: Use WORKDIR instead of cd", [i])
}

# -----------------------------------------------------
# 12. Multi-stage build recommendation (soft warning)
# -----------------------------------------------------

warn[msg] {
  count(froms) < 2
  msg := "Consider using multi-stage builds to reduce image size"
}

froms[i] {
  cmd(i) == "from"
}
