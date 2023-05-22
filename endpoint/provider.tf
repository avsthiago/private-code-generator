terraform {
    required_version = ">=1.4,<=2.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}