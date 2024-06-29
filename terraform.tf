terraform {
  backend "s3" {
    bucket         = "repick-terraform-state-bucket01"
    key            = "server/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "state-locking"
    profile        = "repickdev"
  }
}