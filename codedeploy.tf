module "s3_artifact" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  bucket        = var.s3_artifact_bucket_name
  force_destroy = true
  versioning    = { enabled = false }
}

# CodeDeploy Application
resource "aws_codedeploy_app" "codedeploy_app" {
  compute_platform = "Server"
  name             = "repick-codedeploy-app"
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
  app_name              = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name = "repick-codedeploy-deployment-group"
  service_role_arn      = module.iam_role_codedeploy.iam_role_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "repick-server"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

# IAM Role for CodeDeploy
module "iam_role_codedeploy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.3"

  create_role             = true
  create_instance_profile = true
  role_name               = "codedeploy-role"
  role_requires_mfa       = false

  trusted_role_services = ["ec2.amazonaws.com", "codedeploy.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
    "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
  ]
}