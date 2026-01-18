terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # NOTE: This repo uses terraform-aws-modules/eks, which currently expects
      # aws_launch_template schema compatible with AWS provider v5.x.
      version = ">= 5.0, < 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}


