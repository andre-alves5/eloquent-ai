data "aws_region" "current" {}

# --- ECR Endpoints ---
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_default_security_group.vpc_sg.id]

  tags = {
    Name = "${var.env}-${var.project}-ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_default_security_group.vpc_sg.id]

  tags = {
    Name = "${var.env}-${var.project}-ecr-dkr-endpoint"
  }
}

# --- S3 Gateway Endpoint ---
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for table in aws_route_table.private : table.id]

  tags = {
    Name = "${var.env}-${var.project}-s3-gateway-endpoint"
  }
}

# --- CloudWatch Logs Endpoint ---
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids  = [aws_default_security_group.vpc_sg.id]

  tags = {
    Name = "${var.env}-${var.project}-logs-endpoint"
  }
}
