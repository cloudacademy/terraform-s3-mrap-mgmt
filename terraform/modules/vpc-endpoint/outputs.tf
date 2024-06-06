output "id" {
  value = aws_vpc_endpoint.endpoint.id
}

output "dns" {
  value = aws_vpc_endpoint.endpoint.dns_entry[0].dns_name
}
