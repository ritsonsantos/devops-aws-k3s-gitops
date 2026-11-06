resource "aws_instance" "k3s_lab" {
  count = var.enable_k3s_instance ? 1 : 0

  ami                         = "ami-0aff9f5422d5856d8"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.k3s_nodes.id]
  iam_instance_profile        = aws_iam_instance_profile.k3s_ssm_profile.name
  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    exec > >(tee -a /var/log/k3s-bootstrap.log) 2>&1

    REGION="us-east-1"
    BUCKET="${aws_s3_bucket.k3s_artifacts.bucket}"
    ARTIFACT_DIR="/var/lib/k3s-artifacts"

    mkdir -p "$ARTIFACT_DIR"

    # Aguardar a disponibilidade do AWS CLI e do S3.
    for attempt in $(seq 1 30); do
      if command -v aws >/dev/null 2>&1 &&
         aws s3 ls "s3://$BUCKET/" --region "$REGION"; then
        break
      fi
      echo "Aguardando AWS CLI ou acesso ao S3 ($attempt/30)..."
      sleep 20
    done

    command -v aws >/dev/null 2>&1 || {
      echo "ERRO: AWS CLI não encontrado."
      exit 1
    }

    # Baixar os artefatos necessários.
    aws s3 cp "s3://$BUCKET/k3s" "$ARTIFACT_DIR/k3s" --region "$REGION"
    aws s3 cp "s3://$BUCKET/install.sh" "$ARTIFACT_DIR/install.sh" --region "$REGION"
    aws s3 cp "s3://$BUCKET/k3s-airgap-images-amd64.tar.zst" \
      "$ARTIFACT_DIR/k3s-airgap-images-amd64.tar.zst" --region "$REGION"

    chmod +x "$ARTIFACT_DIR/k3s" "$ARTIFACT_DIR/install.sh"

    # Instalar o binário e as imagens offline do K3s.
    install -D -m 0755 "$ARTIFACT_DIR/k3s" /usr/local/bin/k3s
    mkdir -p /var/lib/rancher/k3s/agent/images
    cp "$ARTIFACT_DIR/k3s-airgap-images-amd64.tar.zst" \
      /var/lib/rancher/k3s/agent/images/

    # Instalar a versão correspondente ao binário enviado.
    export INSTALL_K3S_SKIP_DOWNLOAD=true
    export INSTALL_K3S_SKIP_SELINUX_RPM=true
    export INSTALL_K3S_BIN_DIR=/usr/local/bin
    export INSTALL_K3S_EXEC="server"

    "$ARTIFACT_DIR/install.sh"

    systemctl enable k3s
    systemctl start k3s

    # Habilitar o SSM Agent para acesso administrativo sem SSH.
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "devops-k3s-lab"
    Project = "devops-aws-k3s-gitops"
  }
}
