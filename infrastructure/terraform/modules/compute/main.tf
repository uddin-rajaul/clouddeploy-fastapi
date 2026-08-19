resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  private_ip                  = var.private_ip
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  ebs_optimized               = true
  monitoring                  = false

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = false
    delete_on_termination = true
  }

  tags = {
    Name = "clouddeploy-web-01"
  }
}