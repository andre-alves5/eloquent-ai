locals {
  # Create a mapping from Availability Zone to the NAT Gateway ID in that AZ.
  # This assumes one NAT Gateway per AZ.
  az_to_nat_gateway_id = {
    for k, pub_subnet in aws_subnet.public : pub_subnet.availability_zone => aws_nat_gateway.this[k].id
  }
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    # Look up the correct NAT Gateway using the private subnet's AZ.
    nat_gateway_id = local.az_to_nat_gateway_id[each.value.availability_zone]
  }

  tags = {
    Name = "${var.env}-${var.project}-private-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.env}-${var.project}-public"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
