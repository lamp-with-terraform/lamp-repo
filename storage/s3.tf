# Disable
# Setting up region
provider "aws" {
  region = "us-east-1"
}
#Crating bucket for tfstate
resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "my-tf-state-bucket-0123456789"
  acl    = "private"
}
