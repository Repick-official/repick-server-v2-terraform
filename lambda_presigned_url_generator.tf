data "archive_file" "archive_presigned_url_generator" {
  type        = "zip"
  source_file = "lambda_presigned_url_generator.py"
  output_path = "lambda_presigned_url_generator.zip"
}

resource "aws_lambda_function" "lambda_presigned_url" {
  filename      = data.archive_file.archive_presigned_url_generator.output_path
  function_name = "lambda_presigned-url-generator"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_presigned_url_generator.lambda_handler"
  runtime       = "python3.12"

  source_code_hash = data.archive_file.archive_presigned_url_generator.output_base64sha256

  depends_on = [data.archive_file.archive_presigned_url_generator]

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.repick_admin_bucket.bucket
    }
  }
}

resource "aws_lambda_permission" "s3_invocation_presigned_url" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_presigned_url.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.repick_admin_bucket.arn
}