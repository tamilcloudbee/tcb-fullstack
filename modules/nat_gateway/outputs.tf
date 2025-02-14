output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw[0].id
}

output "nat_eip" {
  value = aws_eip.nat_eip[0].public_ip
}
