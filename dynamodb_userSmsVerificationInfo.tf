resource "aws_dynamodb_table" "userSmsVerificationInfo" {
  name           = "userSmsVerificationInfo"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expirationTime"
    enabled        = true
  }

  tags = {
    Environment = "production"
    Name        = "userSmsVerificationInfo"
  }
}