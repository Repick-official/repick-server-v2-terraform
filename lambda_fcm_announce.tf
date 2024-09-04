data "archive_file" "archive_fcm_announce" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_fcm_announce/"
  output_path = "lambda_fcm_announce.zip"
}


resource "aws_lambda_function" "lambda_fcm_announce" {
  filename      = data.archive_file.archive_fcm_announce.output_path
  function_name = "lambda_fcm_announce"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_fcm_announce.lambda_handler"
  runtime       = "python3.12"

  timeout = 60

  source_code_hash = data.archive_file.archive_fcm_announce.output_base64sha256

  layers = [aws_lambda_layer_version.google_api_client_layer.arn]

  depends_on = [data.archive_file.archive_fcm_announce]

  environment {
    variables = {
      FCM_SERVER_KEY = var.fcm_server_key
      PROJECT_ID     = var.fcm_project_id
    }
  }
}

# Event source mapping for DynamoDB
resource "aws_lambda_event_source_mapping" "ddb_lambda_mapping_announce" {
  event_source_arn  = aws_dynamodb_table.announcement.stream_arn
  function_name     = aws_lambda_function.lambda_fcm_announce.arn
  starting_position = "LATEST"
}