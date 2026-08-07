# Block Public S3 Buckets
package terraform.security

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"

  acl := resource.change.after.acl
  acl == "public-read"

  msg := sprintf("❌ S3 bucket '%s' is public", [resource.name])
}
