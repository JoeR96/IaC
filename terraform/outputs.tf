output "ecr_repository_uri" {
  value = aws_ecr_repository.my_repository.repository_url
  description = "ECR Repository URI"
}
