# Specify the required provider and version for AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider with the specified region
provider "aws" {
  region = var.region
}
