provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.common_tags
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
