
resource "aws_security_group" "k3s_nodes" {
  name        = "devops-k3s-nodes-sg"
  description = "Acesso restrito aos nos K3s"
  vpc_id      = aws_vpc.main.id

  # Permite comunicacao entre recursos deste Security Group
  ingress {
    description = "Comunicacao interna dos nos"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Saida para atualizacoes e downloads
  egress {
    description = "Saida IPv4"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "devops-k3s-nodes-sg"
    Project = "devops-aws-k3s-gitops"
  }
}
