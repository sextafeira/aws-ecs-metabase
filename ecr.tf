resource "aws_ecr_repository" "metabase" {
  name                 = format("%s/metabase", var.project_name)
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = format("%s/metabase", var.project_name)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_ecr_lifecycle_policy" "metabase" {
  repository = aws_ecr_repository.metabase.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Remover imagens sem tag após sete dias"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 7
      }
      action = { type = "expire" }
    }]
  })
}
