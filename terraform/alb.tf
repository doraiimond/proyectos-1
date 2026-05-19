# ─────────────────────────────────────────
# APPLICATION LOAD BALANCER
# ─────────────────────────────────────────

resource "aws_lb" "alb" {
  name               = "proyecto-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [aws_subnet.publica_1.id, aws_subnet.publica_2.id]
  tags               = { Name = "proyecto-alb" }
}

resource "aws_lb_target_group" "tg_ventas" {
  name     = "tg-ventas"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/api/v1/ventas"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "tg_despachos" {
  name     = "tg-despachos"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/api/v1/despachos"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "ventas" {
  target_group_arn = aws_lb_target_group.tg_ventas.arn
  target_id = aws_instance.back_ventas.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "despachos" {
  target_group_arn = aws_lb_target_group.tg_despachos.arn
  target_id = aws_instance.back_despachos.id
  port             = 8081
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_ventas.arn
  }
}

resource "aws_lb_listener_rule" "despachos" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_despachos.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/despachos*"]
    }
  }
}
