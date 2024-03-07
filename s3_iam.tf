resource "aws_iam_user" "s3_user" {
  name = "s3_user"

  tags = {
    Name = "s3_user"
  }
}

resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name = "s3_user_policy"
  user = aws_iam_user.s3_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_secretsmanager_secret" "s3_user_secret" {
  name = "s3_user_secret"
}

resource "aws_secretsmanager_secret_version" "s3_user_secret_version" {
  secret_id = aws_secretsmanager_secret.s3_user_secret.id
  secret_string = jsonencode({
    access_key : aws_iam_access_key.s3_user_key.id,
    secret_key : aws_iam_access_key.s3_user_key.secret
  })
}

