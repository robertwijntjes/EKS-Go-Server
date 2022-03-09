resource "aws_ecr_repository" "go-server-repo" {
  name                 = "go-server-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}