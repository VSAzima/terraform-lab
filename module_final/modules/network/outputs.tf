output "network_self_link" {
  value       = google_compute_network.vpc_network.self_link
  description = "URI of the created VPC"
}

output "subnetwork_self_link" {
  value = google_compute_subnetwork.subnet.self_link
  description = "URI of the created subnetwork"
}

output "firewall_self_link" {
  value       = google_compute_firewall.allow_http.self_link
  description = "URI of the created firewall rule"
}

output "load_balancer_ip" {
  value = google_compute_global_address.lb_static_ip.address
  description = "External IP of the load balancer"
}

output "forwarding_rule_self_link" {
  value = google_compute_global_forwarding_rule.http_forwarding_rule.self_link
  description = "External IP of the load balancer"
}

output "health_check" {
  value        = google_compute_health_check.http.id
  description = "Health check id"
}