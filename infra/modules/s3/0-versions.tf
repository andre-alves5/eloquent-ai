terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.53"
    }
  }
}

data "aws_caller_identity" "current" {}
