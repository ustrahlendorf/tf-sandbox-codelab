resource "aws_subnet" "private" {
  count                   = length(data.aws_availability_zones.current.names)
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  vpc_id                  = aws_vpc.this.id
  availability_zone       = element(data.aws_availability_zones.current.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.base_name}-privSub-${trimprefix( "${element(data.aws_availability_zones.current.names, count.index)}" ,"${data.aws_region.current.name}")}"
    tier = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.base_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(data.aws_availability_zones.current.names)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
