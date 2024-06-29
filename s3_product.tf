resource "aws_s3_bucket" "repick_product_bucket" {
  bucket = "repick-product-bucket"

  tags = {
    Name = "repick-product-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "repick_product_bucket_public_access_block" {
  bucket = aws_s3_bucket.repick_product_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.repick_product_bucket]
}

resource "aws_s3_bucket_policy" "repick_product_bucket_policy" {
  bucket = aws_s3_bucket.repick_product_bucket.id
  policy = data.aws_iam_policy_document.repick_product_bucket_policy.json

  depends_on = [aws_s3_bucket.repick_product_bucket]
}

data "aws_iam_policy_document" "repick_product_bucket_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.repick_product_bucket.arn}",
      "${aws_s3_bucket.repick_product_bucket.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

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

