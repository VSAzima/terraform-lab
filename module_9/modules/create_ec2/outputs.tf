output "instance_id" {
  description = "The created AWS EC2 instance id"
  value       = aws_instance.instance_m9.id
}

output "security_group_id" {
    value = aws_security_group.security_group_m9.id
}