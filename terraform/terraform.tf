terraform {
  backend "s3" {
    bucket = "bestseller-terraform"
    key    = "terraform-state"
    region = "eu-central-1"
  }
}

