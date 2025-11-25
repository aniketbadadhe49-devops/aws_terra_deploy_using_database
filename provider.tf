terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
}
   # 👇 Local backend (stores terraform.tfstate locally)
 # backend "local" {
  #  path = "terraform.tfstate"
 # }
#}

  backend "s3" {
    bucket         = "aniket-s3-tfstate-storege"  # Replace with your S3 bucket name
    key            = "terraform.tfstate" # Path within the bucket
    region         = "ap-south-1"                   # AWS region where the bucket resides
    
  }
}
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
