output "vpc_id" {
  description = "ID da VPC do projeto"
  value       = aws_vpc.main.id
}

output "public_subnet_a_id" {
  description = "ID da sub-rede pública A"
  value       = aws_subnet.public_a.id
}

output "private_subnet_a_id" {
  description = "ID da sub-rede privada A"
  value       = aws_subnet.private_a.id
}
