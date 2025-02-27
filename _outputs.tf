output "aws_cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.default.arn
}

output "feature_url" {
  value = "https://${aws_route53_record.hostnames[0].name}"
}
