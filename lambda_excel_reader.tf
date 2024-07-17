data "archive_file" "archive_excel_reader" {
  type        = "zip"
  source_file = "lambda_excel_reader.py"
  output_path = "lambda_excel_reader.zip"
}

resource "aws_lambda_function" "lambda_excel_reader" {
  filename      = data.archive_file.archive_excel_reader.output_path
  function_name = "lambda_excel_reader"
  role          = aws_iam_role.lambda_excel_reader_exec.arn
  handler       = "lambda_excel_reader.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30

  source_code_hash = data.archive_file.archive_excel_reader.output_base64sha256

  layers = [
    var.layder_pandas
  ]

  depends_on = [data.archive_file.archive_excel_reader]
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_excel_reader_exec" {
  name = "lambda_excel_reader_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Policy for the Lambda execution role
resource "aws_iam_policy" "lambda_excel_reader_exec_policy" {
  name        = "lambda_excel_reader_exec_policy"
  description = "Policy for lambda_excel_reader_exec_policy execution role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::repick-admin-bucket",
          "arn:aws:s3:::repick-admin-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attach" {
  role       = aws_iam_role.lambda_excel_reader_exec.name
  policy_arn = aws_iam_policy.lambda_excel_reader_exec_policy.arn
}

# Permission for S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3_invoke_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_excel_reader.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.repick_admin_bucket.arn
}

# S3 bucket notification
resource "aws_s3_bucket_notification" "excel_reader_notification" {
  bucket = aws_s3_bucket.repick_admin_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_excel_reader.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "excels/"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_lambda]
}
