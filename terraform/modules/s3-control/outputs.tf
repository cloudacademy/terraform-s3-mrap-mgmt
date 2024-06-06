output "arn" {
  value = aws_s3control_multi_region_access_point.mrap[0].arn
}

output "alias" {
  value = aws_s3control_multi_region_access_point.mrap[0].alias
}
