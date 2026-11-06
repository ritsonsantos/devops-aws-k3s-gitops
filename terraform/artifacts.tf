# Bucket privado para armazenar os arquivos de instalacao do K3s
resource "aws_s3_bucket" "k3s_artifacts" {
  bucket_prefix = "ritson-devops-k3s-artifacts-"

  tags = {
    Name    = "devops-k3s-artifacts"
    Project = "devops-aws-k3s-gitops"
  }
}

# Bloquear acesso publico ao bucket
resource "aws_s3_bucket_public_access_block" "k3s_artifacts" {
  bucket = aws_s3_bucket.k3s_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Habilitar versionamento
resource "aws_s3_bucket_versioning" "k3s_artifacts" {
  bucket = aws_s3_bucket.k3s_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Criptografia dos objetos armazenados
resource "aws_s3_bucket_server_side_encryption_configuration" "k3s_artifacts" {
  bucket = aws_s3_bucket.k3s_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Endpoint Gateway para acesso privado ao S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.k3s_artifacts.arn,
          "${aws_s3_bucket.k3s_artifacts.arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name    = "devops-k3s-s3-endpoint"
    Project = "devops-aws-k3s-gitops"
  }
}

# Exibir o nome do bucket apos a criacao
output "k3s_artifacts_bucket" {
  description = "Bucket privado para os artefatos do K3s"
  value       = aws_s3_bucket.k3s_artifacts.bucket
}

