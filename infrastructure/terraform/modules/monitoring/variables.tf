variable "instance_id" {
  description = "EC2 instance ID monitored by CloudWatch"
  type        = string
}

variable "log_group_names" {
  description = "CloudWatch log groups managed by this module"
  type        = set(string)
}