provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "bucket_m10" {
  bucket = "bucket-m10"

}

data "terraform_remote_state" "module_10" {
  backend = "s3"

  config = {
    bucket = "bucket-m10"
    key    = "terraform/state/terraform.tfstate"
    region = "eu-north-1"
  }
}

output "remote_bucket" {
  value = data.terraform_remote_state.module_10.outputs.bucket_id_module_10
}

output "resource_number" {
  value = length(data.terraform_remote_state.module_10.outputs.bucket_id_module_10)
}

data "external" "remote_state_metadata" {
  program = [
    "./scripts/read_metadata.sh",
    "bucket-m10",
    "terraform/state/terraform.tfstate",
    "eu-north-1"
  ]
}

output "remote_state_serial" {
  value = data.external.remote_state_metadata.result.serial
}

output "remote_state_version" {
  value = data.external.remote_state_metadata.result.version
}

