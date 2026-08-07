# Enforce IAM Least Privilege
package terraform.security

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_iam_policy"

  contains(resource.change.after.policy, "\"Effect\":\"Allow\"")
  contains(resource.change.after.policy, "\"Action\":\"*\"")

  msg := sprintf("❌ IAM policy '%s' allows wildcard actions", [resource.name])
}
