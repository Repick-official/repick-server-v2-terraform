resource "aws_dynamodb_table" "userFcmInfo" {
  name             = "userFcmInfo"
  billing_mode     = "PROVISIONED"
  read_capacity    = 5
  write_capacity   = 5
  hash_key         = "userId"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "userId"
    type = "N"
  }

  tags = {
    Environment = "production"
    Name        = "userFcmInfo"
  }
}
