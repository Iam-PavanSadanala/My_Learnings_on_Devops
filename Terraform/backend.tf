terraform {

  backend "s3" {
    bucket         = "terraform-tfstate-archiever"
    key            = "state/terraform.tfstate"
    region         = "ap-south-2"
    encrypt        = true
  }

}

resource "aws_dynamodb_table" "state_lock_table" {
  name           = "terraform_state_lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}