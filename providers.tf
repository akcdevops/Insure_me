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
# Statefile remote backup using s3 bucket and locking with dynamodb
terraform {
  backend "s3" {
    bucket         = "insureme-project"
    key            = "terraform.tfstate.d/${terraform.workspace}/state.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "insuremestatefile"
  }
}

resource "aws_key_pair" "key" {
  key_name   = "ansible"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxgtPvHfKW571RFNumQ3IscxsG6rGh/eZTdBohWs3PmhutRCoyX7xOrbDSa+HJ+pP5ki6ZObCzBwAu9eNWgK4D2cQPGKB44PqPRdPGKUXnPMlIDpmLvpPRJNlcPF2SPliuoyEb26mHHfP4fLhGBr3KfUsxuQRlmLpPwLvxBBle84TXa2J/PKOoZPdQHet4xEJCDIxeS3kF0Hnnzl9YoE5UGISO38j8eTNWSrYVrhhy6WJPM71uj62bVJnfhBYA4kVv6xRcehEHxssImZ4rt/e/jgK15apsIM/PuuzNVhhMKNq02/qjqWeD5MzOCjKapew1NRBmci7z4eQ5EFYZIdRjfdmh14taR21dUY2Fx5/AtIbRmkn1yrysZ45taLZqKzByUsETY1rYC1uwjW44F1cWLib4OJdGDT0c8rBowUEVCWrhKzi0gq/rpRCkinl0/UtahEo6v0uWuC8xfEha+nbwnH92AvagjOvkAURig2lgZAySSG2p0PoLcUg/hyioBQs= akc@Beast"
}
