# infrastructure/modules/ecr/main.tf

resource "aws_ecr_repository" "main" {
  name = var.repository_name

  # Set image scanning to find vulnerabilities on push
  image_scanning_configuration {
    scan_on_push = true
  }

  # Prevent accidental deletion of a repository with images in it
  force_delete = false
}
