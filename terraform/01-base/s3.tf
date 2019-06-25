resource "aws_s3_bucket" "data-kubernetes" {
  bucket = "data-kubernetes"
  acl    = "private"
  tags = {
    Name = "data-kubernetes"
  }

  provisioner "local-exec" {
    command = "bash scripts/copy-config.sh"
  }
}

