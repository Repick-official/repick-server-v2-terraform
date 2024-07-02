resource "aws_s3_bucket" "repick_admin_bucket" {
  bucket = "repick-admin-bucket"

  tags = {
    Name = "repick-admin-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "repick_admin_bucket_public_access_block" {
  bucket = aws_s3_bucket.repick_admin_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}


resource "aws_s3_bucket_policy" "repick_admin_bucket_policy" {
  bucket = aws_s3_bucket.repick_admin_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.repick_admin_bucket.arn}/*"
        Principal = "*"
      },
      {
        Action    = "s3:PutObject"
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.repick_admin_bucket.arn}/*"
        Principal = "*"
      }
    ]
  })
}

resource "aws_iam_role" "repick_admin_bucket_upload_role" {
  name = "s3_upload_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "repick_admin_bucket_upload_policy" {
  name = "s3_upload_policy"
  role = aws_iam_role.repick_admin_bucket_upload_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.repick_admin_bucket.arn,
          "${aws_s3_bucket.repick_admin_bucket.arn}/*"
        ]
      }
    ]
  })
}