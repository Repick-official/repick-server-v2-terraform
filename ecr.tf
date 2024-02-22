resource "aws_ecr_repository" "repick" {
  name                 = "repick-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_registry" {
  description = "The registry ID of the ECR"
  value       = aws_ecr_repository.repick.registry_id
}

output "ecr_repository" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.repick.name
}
