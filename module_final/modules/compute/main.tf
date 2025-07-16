resource "google_compute_instance_template" "template" {
  name           = "apache-template-tf"
  region         = var.region
  
  tags = ["ssh-enabled"]

  disk {
    source_image = var.image_name
    auto_delete  = true
    boot         = true
  }
  
  machine_type         = "e2-micro"

  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnetwork_self_link

    access_config {}

  }
  
    depends_on = [google_compute_region_instance_group_manager.group]

  lifecycle {
    prevent_destroy = false
  }


  metadata = {
    enable-oslogin     = "TRUE"
    serial-port-enable = "TRUE"
    google-logging-enabled = "true"
    
    startup-script = <<-EOT
    #!/bin/bash
      echo "[INFO] Starting startup script" | logger -t startup-script

      apt-get update && echo "[INFO] apt-get update completed" | logger -t startup-script
      apt-get install -y apache2 && echo "[INFO] apache2 installed" | logger -t startup-script

      sed -i 's/80/8080/g' /etc/apache2/ports.conf && echo "[INFO] Updated ports.conf" | logger -t startup-script
      sed -i 's/80/8080/g' /etc/apache2/sites-enabled/000-default.conf && echo "[INFO] Updated site config" | logger -t startup-script

      SERVER_NUMBER=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/server_number)
      HOSTNAME=$(hostname)
      echo "<html><body><h1>Hostname: \$${HOSTNAME}</h1><h2>Server Number: \$${SERVER_NUMBER}</h2></body></html>" > /var/www/html/index.html
      echo "[INFO] Wrote index.html with hostname and server number" | logger -t startup-script

      systemctl enable apache2 && echo "[INFO] apache2 enabled on boot" | logger -t startup-script
      systemctl restart apache2 && echo "[INFO] apache2 restarted" | logger -t startup-script
    EOT
  }
}

resource "google_compute_region_instance_group_manager" "group" {
  name               = "mig-tf"
  region             = var.region
  base_instance_name = "apache"
  target_size        = var.instance_count
  named_port {
    name = "http"
    port = 8080
  }

   version {
    instance_template = google_compute_instance_template.template.self_link
    name              = "v1" 
  }

  lifecycle {
    prevent_destroy = false
  }

  update_policy {
  type                    = "OPPORTUNISTIC"
  minimal_action          = "RESTART"
  max_surge_fixed         = 1
  max_unavailable_fixed   = 0
}

  auto_healing_policies {
    health_check      = var.health_check
    initial_delay_sec = 30
  }

}


