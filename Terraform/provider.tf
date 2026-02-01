terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "ap-south-2"
    shared_credentials_files = [ "C:\\Users\\Srujana Sree\\.aws\\credentials" ]         
}