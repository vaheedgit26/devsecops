# Enforce Mandatory Tags
package terraform.security

required_tags := ["Owner", "Environment"]

deny[msg] {
  resource := input.resource_changes[_]
  tags := resource.change.after.tags

  some tag
  required_tags[tag]

  not tags[tag]

  msg := sprintf("❌ Resource '%s' missing tag '%s'", [resource.name, tag])
}
