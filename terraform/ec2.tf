
resource "aws_instance" "k3s_lab" {
  ami                         = "ami-0aff9f5422d5856d8"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.k3s_nodes.id]
  iam_instance_profile        = aws_iam_instance_profile.k3s_ssm_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "devops-k3s-lab"
    Project = "devops-aws-k3s-gitops"
  }
}

