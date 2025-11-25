terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
}
   # 👇 Local backend (stores terraform.tfstate locally)
  backend "local" {
    path = "terraform.tfstate"
  }
}

  backend "s3" {
    bucket         = "aniket-s3-tfstate-bucket-name"  # Replace with your S3 bucket name
    key            = "terraform.tfstate" # Path within the bucket
    region         = "us-east-1"                   # AWS region where the bucket resides
    encrypt        = true                          # Optional: Encrypt the state file at rest
    dynamodb_table = "your-dynamodb-lock-table"    # Optional: For state locking (recommended)
  }
}
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
