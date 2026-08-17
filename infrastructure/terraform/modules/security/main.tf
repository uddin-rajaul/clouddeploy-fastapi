resource "aws_security_group" "rds" {
  name        = "clouddeploy-rds-sg"
  description = "Security group for CloudDeploy RDS PostgreSQL"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = false

  tags = {
    Name = "clouddeploy-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_postgres" {
  security_group_id = aws_security_group.rds.id
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  referenced_security_group_id = var.web_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}