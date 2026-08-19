resource "aws_db_subnet_group" "this" {
  name        = "clouddeploy-db-subnet-group"
  description = "Private subnets for CloudDeploy PostgreSQL"
  subnet_ids  = var.subnet_ids
}

resource "aws_db_instance" "this" {
    identifier = "clouddeploy-postgres"

    engine = "postgres"
    engine_version = "18.3"
    instance_class = "db.t4g.micro"

    allocated_storage = 20
    storage_type = "gp2"
    storage_encrypted = true
    max_allocated_storage = 0

    db_subnet_group_name = aws_db_subnet_group.this.name
    vpc_security_group_ids = [var.rds_security_group_id]

    publicly_accessible = false
    port = 5432
    availability_zone = "ap-south-1a"

    backup_retention_period = 1
    deletion_protection = false

    copy_tags_to_snapshot  = true

    skip_final_snapshot = true
}