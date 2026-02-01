terraform {

  backend "s3" {
    bucket         = "terraform-tfstate-archiever"
    key            = "state/terraform.tfstate"
    region         = "ap-south-2"
    encrypt        = true
  }

}