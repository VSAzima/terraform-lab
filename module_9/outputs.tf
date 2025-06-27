output "instance_id" {
  description = "The created AWS EC2 instance id"
  value       = module.create_ec2.instance_id
}

output "security_group_id" {
    value = module.create_ec2.security_group_id
}