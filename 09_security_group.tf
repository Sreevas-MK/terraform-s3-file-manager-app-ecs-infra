# Security group for Load balancer

resource "aws_security_group" "load_balancer" {

  vpc_id      = aws_vpc.main.id
  name        = "${var.project_name}-${var.project_env}-loadbalancer"
  description = "${var.project_name}-${var.project_env}-loadbalancer"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description     = "HTTP from Internet"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id] # CloudFront managed prefix list
  }


  tags = {
    Environment = var.project_env
    Project     = var.project_name
    Owner       = var.project_owner
  }
}


# Security group for backend

resource "aws_security_group" "ecs" {

  vpc_id      = aws_vpc.main.id
  name        = "${var.project_name}-${var.project_env}-ecs"
  description = "${var.project_name}-${var.project_env}-ecs"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description     = "HTTP from loadbalancer"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  #   ingress {
  #     description = "Allow HTTPS for VPC Endpoints"
  #     from_port   = 443
  #     to_port     = 443
  #     protocol    = "tcp"
  #     self        = true
  #     cidr_blocks = [var.vpc_cidr_block]
  #   }

  tags = {
    Environment = var.project_env
    Project     = var.project_name
    Owner       = var.project_owner
  }
}
