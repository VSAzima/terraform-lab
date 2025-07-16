terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.28.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "network" {
  source             = "./modules/network"
  project_id         = var.project_id
  region             = var.region
  allowed_ips        = var.allowed_ips
  instance_group_url = module.compute.instance_group_url
}

module "compute" {
  source               = "./modules/compute"
  project_id           = var.project_id
  region               = var.region
  zone                 = var.zone
  network_self_link    = module.network.network_self_link
  subnetwork_self_link = module.network.subnetwork_self_link
  image_name           = var.golden_image_name
  instance_count       = var.instance_count
  health_check         = module.network.health_check
}




