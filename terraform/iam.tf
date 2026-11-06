resource "aws_iam_role" "k3s_ssm_role" {
  name = "devops-k3s-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = "devops-aws-k3s-gitops"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.k3s_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "k3s_ssm_profile" {
  name = "devops-k3s-ssm-profile"
  role = aws_iam_role.k3s_ssm_role.name
}

# Permitir que a EC2 leia os artefatos do K3s no S3
resource "aws_iam_role_policy" "k3s_artifacts_read" {
  name = "devops-k3s-artifacts-read"
  role = aws_iam_role.k3s_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.k3s_artifacts.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.k3s_artifacts.arn}/*"
      }
    ]
  })
}
