terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "bucket_m10l31" {
  bucket = "bucket-l31"

}

resource "aws_s3_bucket" "bucket_m10l32" {
  bucket = "bucket-l32"

  depends_on = [
    aws_s3_bucket.bucket_m10l31
  ]
}

resource "aws_s3_bucket" "bucket_m10l33" {
  bucket = "bucket-l33"

  depends_on = [
    aws_s3_bucket.bucket_m10l32,
    aws_s3_bucket.bucket_m10l31
  ]
}

