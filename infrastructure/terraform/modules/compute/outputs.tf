output "instance_id" {
  value = aws_instance.web.id
}

output "private_ip" {
  value = aws_instance.web.private_ip
}

output "public_ip" {
  value = aws_instance.web.public_ip
}