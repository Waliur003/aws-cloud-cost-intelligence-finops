//Declare the terraform block and specify the required version of Terraform
terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "FinOps-Cost-Intelligence"
      ManagedBy = "Terraform"
    }
  }
}