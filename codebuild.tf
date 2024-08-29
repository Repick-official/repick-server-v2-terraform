# Deleted: CI on Github Actions; only need CodeDeploy
#
#resource "aws_codebuild_project" "codebuild" {
#  name          = "repick-codebuild"
#  build_timeout = 60
#  service_role  = module.iam_role_codebuild.iam_role_arn
#
#  source {
#    type     = "GITHUB"
#    location = "https://github.com/Repick-official/repick-server-v2.git"
#    git_clone_depth = 1
#  }
#
#  source_version = "feature/codepipeline"
#
#  environment {
#    compute_type    = "BUILD_GENERAL1_SMALL"
#    image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
#    type            = "LINUX_CONTAINER"
#    privileged_mode = false
#  }
#
#  artifacts {
#    type = "NO_ARTIFACTS"
#  }
#
#}
#
#module "iam_role_codebuild" {
#  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#  version = "~> 4.3"
#
#  create_role             = true
#  create_instance_profile = true
#  role_name               = "codebuild-role"
#  role_requires_mfa       = false
#
#  trusted_role_services = ["codebuild.amazonaws.com"]
#  custom_role_policy_arns = [
#    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
#    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
#    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
#    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
#  ]
#}