resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${var.project_env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.project_env}"
  }
}

# Creating public subnets

resource "aws_subnet" "public_subnets" {

  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = var.zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.project_env}-public_${count.index + 1}"
  }
}

# Creating private subnets

resource "aws_subnet" "private_subnets" {

  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, count.index + 2)
  map_public_ip_on_launch = false
  availability_zone       = var.zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.project_env}-private_${count.index + 1}"
  }
}

# Creating a route table

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-${var.project_env}-public"
  }
}

# Associating route tables for public subnets
resource "aws_route_table_association" "public_subnet" {

  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route.id
}

# Associating Elastic IP
resource "aws_eip" "nat" {
  count = var.enable_nat_gw == true ? 1 : 0
  # If condition is true, the count value will be 1.
  # If it is false, the count value will be 0.
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-${var.project_env}-nat"
  }
}

# The result will be stored as a list

# Adding NAT gateway
resource "aws_nat_gateway" "nat-gateway-main" {
  count         = var.enable_nat_gw == true ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  # We need to fetch 0th element from list created in above step
  subnet_id = aws_subnet.public_subnets[0].id

  # Any public subnet
  tags = {
    Name = "${var.project_name}-${var.project_env}-nat-gateway-main"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Creating private route via NAT gateway

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.project_env}-private_route"
  }
}

resource "aws_route" "nat_gw_route" {
  count                  = var.enable_nat_gw == true ? 1 : 0
  route_table_id         = aws_route_table.private_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gateway-main[0].id
}

# Associating private route tables
resource "aws_route_table_association" "private_subnet" {
  count = 2

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route.id
}
# 
# 
# # 1. ECR API Interface Endpoint
# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.ap-south-1.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private_subnets[*].id
#   security_group_ids  = [aws_security_group.ecs.id]
#   private_dns_enabled = true
# }
# 
# # 2. ECR Docker Interface Endpoint (Handles the actual image pull)
# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.ap-south-1.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private_subnets[*].id
#   security_group_ids  = [aws_security_group.ecs.id]
#   private_dns_enabled = true
# }
# 
# # 3. S3 Gateway Endpoint (ECR stores image layers in S3)
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.ap-south-1.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = [aws_route_table.private_route.id]
# }
# 
# # 4. CloudWatch Logs Interface Endpoint
# resource "aws_vpc_endpoint" "logs" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.ap-south-1.logs" # ap-south-1 for Mumbai
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private_subnets[*].id
#   security_group_ids  = [aws_security_group.ecs.id]
#   private_dns_enabled = true
# }
