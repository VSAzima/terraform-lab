output "instance_group_url" {
  value       = google_compute_region_instance_group_manager.group.instance_group
  description = "URL of the managed instance group"
}

