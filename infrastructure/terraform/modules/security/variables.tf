variable "vpc_id" {
  description = "CloudDeploy VPC ID"
  type        = string
}

variable "web_security_group_id" {
  description = "Security group allowed to access PostgreSQL"
  type        = string
}