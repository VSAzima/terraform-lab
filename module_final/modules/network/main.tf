resource "google_compute_network" "vpc_network" {
  name = "vpc-tf"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-tf"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-from-ip-range-tf"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = var.allowed_ips
}

resource "google_compute_global_address" "lb_static_ip" {
  name = "apache-lb-ip-tf"
}

resource "google_compute_health_check" "http" {
  name                 = "health-check-tf"
  check_interval_sec   = 5
  timeout_sec          = 5
  healthy_threshold    = 2
  unhealthy_threshold  = 2

  http_health_check {
    port = 8080
    request_path = "/"
  }
}

resource "google_compute_backend_service" "default" {
  name                            = "apache-backend"
  load_balancing_scheme           = "EXTERNAL"
  protocol                        = "HTTP"
  port_name                       = "http"
  timeout_sec                     = 10
  health_checks                   = [google_compute_health_check.http.id]

  backend {
    group = var.instance_group_url 
  }

  depends_on = [google_compute_health_check.http]
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map-tf"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy-tf"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name                  = "fw-rule-tf"
  target                = google_compute_target_http_proxy.http_proxy.id
  port_range            = "8080"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.lb_static_ip.address
}

resource "google_compute_route" "default_internet_route" {
  name                   = "default-internet-route"
  network                = google_compute_network.vpc_network.name
  dest_range             = "0.0.0.0/0"
  next_hop_gateway       = "default-internet-gateway"
  priority               = 1000
}

resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check-tf"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] 
  target_tags   = ["web-server"]

    lifecycle {
    create_before_destroy = true
    prevent_destroy      = false
  }

}


resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["82.117.193.213/32"]

  target_tags = ["ssh-enabled"]
}