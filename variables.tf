variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "common_tags" {
  type = map(any)
  default = {
    Project   = "minature-enigma"
    ManagedBy = "terraform"
    env       = "dev"
  }
}

variable "source_account" {
  type    = string
  default = "0123456789"
}

variable "destination_account" {
  type    = string
  default = "9876543210"
}

variable "source_bucket_arn" {
  type    = string
  default = "arn:aws:s3:::source-bucket"
}

variable "destination_bucket_arn" {
  type    = string
  default = "arn:aws:s3:::destination-bucket"
}