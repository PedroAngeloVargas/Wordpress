resource "aws_lb" "load_balancer" {
  name                       = "meualb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.grupo_seguranca_publico.id]
  subnets                    = [aws_subnet.minha_subnet_publica1.id, aws_subnet.minha_subnet_publica2.id]
  enable_deletion_protection = false

  tags = {
    Name = "Load Balancer"
  }

}

resource "aws_lb_target_group" "health-check" {
  name     = "health-check"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.minha_vpc.id


  health_check {
    enabled             = true
    path                = "/"
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-304"
    protocol            = "HTTP"
    interval            = 30
  }


  tags = {
    Name = "health check para o asg"
  }


}

resource "aws_lb_listener" "listen" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.health-check.arn
  }
}

