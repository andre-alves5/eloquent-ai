resource "aws_subnet" "private" {
  for_each = var.private-subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = merge({
    Name = "${var.env}-private-${each.key}"
  })
}

resource "aws_subnet" "public" {
  for_each = var.public-subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = merge({
    Name = "${var.env}-public-${each.key}"
  })
}
