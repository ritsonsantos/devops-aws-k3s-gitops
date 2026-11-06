resource "aws_security_group" "ssm_endpoint" {
  name        = "devops-k3s-ssm-endpoint-sg"
  description = "HTTPS da EC2 para endpoints SSM"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTPS da instancia K3s"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.k3s_nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "devops-k3s-ssm-endpoint-sg"
    Project = "devops-aws-k3s-gitops"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id]
  security_group_ids  = [aws_security_group.ssm_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name    = "devops-k3s-ssm"
    Project = "devops-aws-k3s-gitops"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id]
  security_group_ids  = [aws_security_group.ssm_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name    = "devops-k3s-ssmmessages"
    Project = "devops-aws-k3s-gitops"
  }
}
