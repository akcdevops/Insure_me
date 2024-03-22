terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}
#Statefile remote backup using s3 bucket and locking with dynamodb
terraform {
  backend "s3" {
    bucket         = "insureme-project"
    key            = "terraform.tfstate.d/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "insuremestatefile"
  }
}


