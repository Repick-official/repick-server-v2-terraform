resource "aws_dynamodb_table" "userPreference" {
  name           = "userPreference"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "userId"

  attribute {
    name = "userId"
    type = "N"
  }

  tags = {
    Environment = "production"
    Name        = "userPreference"
  }
}