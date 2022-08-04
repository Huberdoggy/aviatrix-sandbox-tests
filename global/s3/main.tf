terraform {
  backend "s3" {
    bucket  = "kyle-aviatrix-s3-bucket"
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-1" # vars can't be used here...
    profile = "development"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "development"
}

# TF CAN NOT simultaneously create and use S3 as backend in the same run. Workaround - comment out backend config, init/apply the creation, then re-run with backend config set

# terraform init -reconfigure \
# -backend-config="bucket=kyle-aviatrix-s3-bucket" \
# -backend-config="key=global/s3/terraform.tfstate" \
# -backend-config="region=us-east-1"

resource "aws_s3_bucket" "kyle-aviatrix-s3-bucket" {
  bucket        = var.bucket_name
  force_destroy = true // Force removal of all files/versions from bucket to prevent errors when I'm done
}

resource "aws_s3_bucket_versioning" "versioning-disabled" {
  bucket = var.bucket_name
  versioning_configuration {
    status = "Disabled" # I don't really need it for this experiment
  }
}
