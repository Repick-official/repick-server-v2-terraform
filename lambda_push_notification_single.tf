data "archive_file" "archive_push_notification_single" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_push_notification_single/"
  output_path = "lambda_push_notification_single.zip"
}

resource "aws_lambda_function" "lambda_push_notification_single" {
  filename      = data.archive_file.archive_push_notification_single.output_path
  function_name = "lambda_push_notification_single"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_push_notification_single.lambda_handler"
  runtime       = "python3.12"

  source_code_hash = data.archive_file.archive_push_notification_single.output_base64sha256

  timeout = 60

  layers = [aws_lambda_layer_version.google_api_client_layer.arn]

  depends_on = [data.archive_file.archive_push_notification_single]

  environment {
    variables = {
      FCM_SERVER_KEY = var.fcm_server_key
      PROJECT_ID     = var.fcm_project_id
    }
  }
}

resource "aws_lambda_layer_version" "google_api_client_layer" {
  filename            = "google-api-python-client.zip"
  layer_name          = "google-api-python-client-layer"
  compatible_runtimes = ["python3.12"]

  description = "Google API Python Client Layer for Python 3.12"
}
