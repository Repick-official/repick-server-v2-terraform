data "archive_file" "archive_fcm_subscribe" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_fcm_subscribe/"
  output_path = "lambda_fcm_subscribe.zip"
}

resource "aws_lambda_function" "lambda_fcm_subscribe" {
  filename      = data.archive_file.archive_fcm_subscribe.output_path
  function_name = "lambda_fcm_subscribe"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_fcm_subscribe.lambda_handler"
  runtime       = "python3.12"

  source_code_hash = data.archive_file.archive_fcm_subscribe.output_base64sha256

  timeout = 60

  layers = [aws_lambda_layer_version.firebase_admin_layer.arn]

  depends_on = [data.archive_file.archive_fcm_subscribe]

}

resource "aws_lambda_layer_version" "firebase_admin_layer" {
  filename            = "firebase_admin.zip"
  layer_name          = "firebase_admin"
  compatible_runtimes = ["python3.12"]

  description = "Google API Python Client Layer for Python 3.12"
}

# Event source mapping for DynamoDB
resource "aws_lambda_event_source_mapping" "ddb_lambda_mapping_subscribe" {
  event_source_arn  = aws_dynamodb_table.userFcmInfo.stream_arn
  function_name     = aws_lambda_function.lambda_fcm_subscribe.arn
  starting_position = "LATEST"
}