variable "subnet_ids" {
  description = "Private subnet IDs used by the RDS DB subnet group"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security group ID used by the PostgreSQL RDS instance"
  type        = string
}