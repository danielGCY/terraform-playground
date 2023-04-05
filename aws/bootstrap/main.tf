terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "random_string" "state_bucket_name_suffix" {
  length = 16
  special = false
  upper = false
}

module "s3" {
  source = "../modules/s3"

  bucket_name = "terraform-playground-state-bucket-${random_string.state_bucket_name_suffix.result}"
}