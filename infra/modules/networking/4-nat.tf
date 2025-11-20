resource "aws_eip" "this" {
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = {
    Name = "${var.env}-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each = aws_subnet.public

  subnet_id     = each.value.id
  allocation_id = aws_eip.this[each.key].id

  tags = {
    Name = "${var.env}-nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.this]
}
