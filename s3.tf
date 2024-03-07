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