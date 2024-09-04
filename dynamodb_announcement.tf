resource "aws_dynamodb_table" "announcement" {
  name           = "announcement"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "production"
    Name        = "announcement"
  }
}
