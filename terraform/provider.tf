terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.62"
    }
  }
  backend "s3" {
    bucket = "devops-bootcamp-terraform-nik-muhammad-arif-adlan"
    key    = "terraform/terraform.tfstate"
    region = "ap-southeast-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_caller_identity" "current" {}