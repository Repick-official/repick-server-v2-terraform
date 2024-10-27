data "archive_file" "archive_thumbnail_generator" {
  type        = "zip"
  source_file = "lambda_thumbnail_generator.py"
  output_path = "lambda_thumbnail_generator.zip"
}

resource "aws_lambda_function" "lambda_thumbnail" {
  filename      = data.archive_file.archive_thumbnail_generator.output_path
  function_name = "lambda_thumbnail-generator"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_thumbnail_generator.lambda_handler"
  runtime       = "python3.12"

  source_code_hash = data.archive_file.archive_thumbnail_generator.output_base64sha256

  layers = [
    var.layer_arn
  ]

  depends_on = [data.archive_file.archive_thumbnail_generator]
}

resource "aws_s3_bucket_notification" "example_notification" {
  bucket = aws_s3_bucket.repick_product_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_thumbnail.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "product/thumbnail/"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = "s3:*"
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.repick_product_bucket.arn,
          "${aws_s3_bucket.repick_product_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_permission" "s3_invocation" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_thumbnail.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.repick_product_bucket.arn
}

# Add an IAM policy for lambda exec role to get access
resource "aws_iam_role_policy" "lambda_dynamodb_stream_policy" {
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}