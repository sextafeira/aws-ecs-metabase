resource "aws_lb" "metabase" {
  name                       = var.project_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]
  drop_invalid_header_fields = true
  enable_deletion_protection = var.deletion_protection
  idle_timeout               = 120

  tags = {
    Name        = var.project_name
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_lb_target_group" "main" {
  name                 = format("%s-main", var.project_name)
  port                 = 3000
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.main.id
  deregistration_delay = 120
  health_check {
    path                = "/api/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = format("%s-main", var.project_name)
    Environment = var.environment
    Terraform   = "True"
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.metabase.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      host        = var.domain_name
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name        = format("%s-http", var.project_name)
    Environment = var.environment
    Terraform   = "True"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.metabase.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.metabase.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = {
    Name        = format("%s-https", var.project_name)
    Environment = var.environment
    Terraform   = "True"
  }
}

