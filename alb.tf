resource "aws_lb" "repick" {
  name               = "repick-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.repick-sg.id]
    subnets            = [aws_subnet.repick-vpc-public-subnet-1.id, aws_subnet.repick-vpc-public-subnet-2.id]

  tags = {
    Name = "repick-alb"
  }
}

resource "aws_lb_target_group" "repick" {
  name     = "repick-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.repick-vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = var.aws_lb_target_group_health_check_path
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "repick-tg"
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.repick.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.repick.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.repick_certificate_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.repick.arn
  }
}


resource "aws_lb_target_group_attachment" "repick" {
  target_group_arn = aws_lb_target_group.repick.arn
  target_id        = aws_instance.webserver.id
  port             = var.aws_lb_target_group_attachment_port
}
