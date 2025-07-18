resource "google_compute_instance_template" "template" {
  name_prefix           = "apache-template-tf-"
  region                = var.region
  
  tags = ["web-server",
          "ssh-enabled"]

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
  


  lifecycle {
    create_before_destroy = true
    prevent_destroy      = false
  }


    metadata = {
      enable-oslogin         = "TRUE"
      serial-port-enable     = "TRUE"
      google-logging-enabled = "true"
      script-version         = "v2-${timestamp()}"
  
      startup-script = <<-EOT
  #!/bin/bash
  set -euxo pipefail 

  apt-get update
  apt-get install -y apache2
  sed -i 's/Listen 80/Listen 8888/' /etc/apache2/ports.conf
  sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8888>/' /etc/apache2/sites-enabled/000-default.conf
  systemctl restart apache2

  WEB_ROOT="/var/www/html"
  LOG_FILE="/var/log/startup-script.log"
  
  mkdir -p "$WEB_ROOT"
  
  log() {
    echo "$1" | tee -a "$LOG_FILE"
  }
  cat /etc/apache2/ports.conf

  cat /etc/apache2/sites-enabled/000-default.conf

  log "Fetching server_number from metadata..."
  SERVER_NUMBER=$(curl -sf -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/server_number" || true)
  
  if [ -z "$SERVER_NUMBER" ]; then
      log "server_number not found, falling back to instance ID..."
      SERVER_NUMBER=$(curl -sf -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/id" || echo "UNKNOWN")
  fi
  
  HOSTNAME=$(hostname || echo "unknown-host")
  
  log "SERVER_NUMBER: $SERVER_NUMBER"
  log "HOSTNAME: $HOSTNAME"
  
  
  cat <<EOF > "$WEB_ROOT/index.html"
  <!DOCTYPE html>
  <html>
  <head>
    <title>Server Info</title>
  </head>
  <body>
    <h1>Server #$SERVER_NUMBER</h1>
    <p>Hostname: $HOSTNAME</p>
  </body>
  </html>
  EOF
  
  log "Startup script completed successfully."
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
    port = 8888
  }

   version {
    instance_template = google_compute_instance_template.template.self_link
    name              = "v1" 
  }

  lifecycle {
    prevent_destroy = false
    create_before_destroy = true
  }

  update_policy {
    type                          = "PROACTIVE"
    minimal_action                = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed               = 3
    max_unavailable_fixed         = 0
    replacement_method            = "SUBSTITUTE"
  }

  auto_healing_policies {
    health_check      = var.health_check
    initial_delay_sec = 600
  }

}


