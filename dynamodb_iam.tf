resource "aws_iam_user" "dynamodb_user" {
  name = "dynamodb_user"
  path = "/system/"
}

resource "aws_iam_access_key" "dynamodb_user_key" {
  user = aws_iam_user.dynamodb_user.name
}

resource "aws_iam_user_policy" "dynamodb_full_access" {
  name = "dynamodb_full_access"
  user = aws_iam_user.dynamodb_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "dynamodb:*",
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_secretsmanager_secret" "dynamodb_user_key" {
  name = "dynamodb_user_key"
}

resource "aws_secretsmanager_secret_version" "dynamodb_user_key" {
  secret_id = aws_secretsmanager_secret.dynamodb_user_key.id
  secret_string = jsonencode({
    access_key = aws_iam_access_key.dynamodb_user_key.id
    secret_key = aws_iam_access_key.dynamodb_user_key.secret
  })
}