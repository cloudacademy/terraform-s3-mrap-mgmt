output "role_name" {
  value = aws_iam_role.s3_replication.name
}

output "role_arn" {
  value = aws_iam_role.s3_replication.arn
}
