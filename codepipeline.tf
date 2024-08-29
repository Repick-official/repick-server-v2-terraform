# Deleted: CI on Github Actions; only need CodeDeploy
#
#resource "aws_codepipeline" "codepipeline" {
#  name     = "repick-codepipeline"
#  role_arn = module.iam_role_codepipeline.iam_role_arn
#
#  artifact_store {
#    location = var.s3_artifact_bucket_name
#    type     = "S3"
#  }
#
#  stage {
#    name = "Source"
#    action {
#      name             = "Source"
#      category         = "Source"
#      owner            = "AWS"
#      provider         = "CodeStarSourceConnection"
#      version          = "1"
#      output_artifacts = ["source_output"]
#
#      configuration = {
#        ConnectionArn    = aws_codestarconnections_connection.this.arn
#        FullRepositoryId = "Repick-official/repick-server-v2"
#        BranchName       = "feature/codepipeline"
#      }
#    }
#  }
#
#  stage {
#    name = "Build"
#    action {
#      name             = "Build"
#      category         = "Build"
#      owner            = "AWS"
#      provider         = "CodeBuild"
#      input_artifacts  = ["source_output"]
#      output_artifacts = ["build_output"]
#      version          = "1"
#
#      configuration = {
#        ProjectName = aws_codebuild_project.codebuild.name
#      }
#    }
#  }
#
#  stage {
#    name = "Approve"
#    action {
#      name     = "Approval"
#      category = "Approval"
#      owner    = "AWS"
#      provider = "Manual"
#      version  = "1"
#    }
#  }
#
#  stage {
#    name = "Deploy"
#    action {
#      name            = "Deploy"
#      category        = "Deploy"
#      owner           = "AWS"
#      provider        = "CodeDeploy"
#      input_artifacts = ["build_output"]
#      version         = "1"
#
#      configuration = {
#        ApplicationName     = aws_codedeploy_app.codedeploy_app.name
#        DeploymentGroupName = aws_codedeploy_deployment_group.codedeploy_deployment_group.deployment_group_name
#      }
#    }
#  }
#
#}
#
#resource "aws_codestarconnections_connection" "this" {
#  name          = "repick-codepipeline-connection"
#  provider_type = "GitHub"
#}
#
#module "iam_role_codepipeline" {
#  source                  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#  version                 = "~> 4.3"
#  create_role             = true
#  create_instance_profile = true
#  role_name               = "codepipeline-role"
#  role_requires_mfa       = false
#  trusted_role_services   = ["codepipeline.amazonaws.com"]
#  custom_role_policy_arns = [
#    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
#    "arn:aws:iam::aws:policy/AWSCodeStarFullAccess",
#    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
#    "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess",
#  ]
#}
#