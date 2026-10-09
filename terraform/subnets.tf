
# Consultar zonas de disponibilidade da região
data "aws_availability_zones" "available" {
  state = "available"
}

# Sub-rede pública na primeira zona
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-k3s-public-a"
    Tier = "public"
  }
}

# Sub-rede privada na primeira zona
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "devops-k3s-private-a"
    Tier = "private"
  }
}

# Sub-rede pública na segunda zona
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-k3s-public-b"
    Tier = "public"
  }
}

# Sub-rede privada na segunda zona
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "devops-k3s-private-b"
    Tier = "private"
  }
}
