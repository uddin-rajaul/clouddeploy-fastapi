output "log_group_names" {
  description = "Managed CloudWatch log group names"
  value       = [for group in aws_cloudwatch_log_group.nginx : group.name]
}

output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu.arn
}

output "instance_status_check_alarm_arn" {
  description = "ARN of the EC2 status check alarm"
  value       = aws_cloudwatch_metric_alarm.instance_status_check.arn
}