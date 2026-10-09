
# Rede principal do projeto
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "devops-k3s-vpc"
    Project = "devops-aws-k3s-gitops"
  }
}

# Internet Gateway para as sub-redes públicas
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-k3s-igw"
  }
}
