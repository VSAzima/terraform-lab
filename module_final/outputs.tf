output "network_self_link" {
  value = module.network.network_self_link
}

output "subnetwork_self_link" {
  value = module.network.subnetwork_self_link
}

output "load_balancer_ip" {
  value = module.network.load_balancer_ip
}

output "load_balancer_static_ip" {
  value = module.network.load_balancer_ip
}

output "health_check" {
  value = module.network.health_check
}

output "instance_group_url" {
  value       = module.compute.instance_group_url
  description = "URL of the managed instance group"
}
