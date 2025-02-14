resource "aws_eip" "nat_eip" {
  count = var.create_nat_gateway ? 1 : 0
  domain   = "vpc"

  tags = {
    Name = "${var.resource_prefix}-nat-eip-${var.env_name}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "${var.resource_prefix}-nat-gateway-${var.env_name}"
  }

  depends_on = [aws_eip.nat_eip]
}

resource "aws_route" "private_subnet_route" {
  count                  = var.create_nat_gateway ? 1 : 0
  route_table_id         = var.private_routetable_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id

  depends_on = [aws_nat_gateway.nat_gw]
}
