resource "aws_lb" "s3_app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "alb-logs"
    enabled = true
  }

  tags = {
    Environment = var.project_env
    Owner       = var.project_owner
  }
}

resource "aws_lb_target_group" "s3_app_tg" {

  name_prefix          = "s3tg-"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 10

  health_check {

    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 20
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2

  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb_listener" "frontend_http_listener" {

  load_balancer_arn = aws_lb.s3_app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.s3_app_tg.arn
  }
}
