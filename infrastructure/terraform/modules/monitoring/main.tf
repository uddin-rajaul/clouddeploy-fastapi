resource "aws_cloudwatch_log_group" "nginx" {
  for_each = var.log_group_names

  name = each.value
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "clouddeploy-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "cpu_usage_idle"
  namespace           = "CloudDeploy"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  datapoints_to_alarm = 1

  dimensions = {
    InstanceId = var.instance_id
    cpu        = "cpu-total"
  }

  treat_missing_data = "missing"
}

resource "aws_cloudwatch_metric_alarm" "instance_status_check" {
  alarm_name          = "clouddeploy-instance-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  datapoints_to_alarm = 1

  dimensions = {
    InstanceId = var.instance_id
  }

  treat_missing_data = "missing"
}