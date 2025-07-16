terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
      bucket  = "bucket-m10"
      key    = "terraform/state/terraform.tfstate"
      region = "eu-north-1"
    }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "bucket_m10" {
  bucket = "bucket-m10"

}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.bucket_m10.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.bucket_m10.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "full_access_to_account" {
  bucket = aws_s3_bucket.bucket_m10.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowFullAccessToAccount"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::418272767424:root"
        }
        Action   = "s3:*"
        Resource = [
          "arn:aws:s3:::bucket-m10",
          "arn:aws:s3:::bucket-m10/*"
        ]
      }
    ]
  })
}

output "bucket_id_module_10" {
  description = "The ID of the imported S3 bucket"
  value       = aws_s3_bucket.bucket_m10.id 
}
