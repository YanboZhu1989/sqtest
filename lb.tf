/* resource "aws_lb" "front_end" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_webtier.id]
  subnets            = aws_subnet.public_subnets.*.id

  enable_deletion_protection = false
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "lb-frontend-target"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id 
}  */

resource "aws_lb" "apptier" {
  name               = "apptier-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_apptier.id]
  subnets            = aws_subnet.public_subnets.*.id

  enable_deletion_protection = false
}

resource "aws_lb_listener" "apptier" {
  load_balancer_arn = aws_lb.apptier.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apptier.arn
  }
}

resource "aws_lb_target_group" "apptier" {
  name        = "lb-apptier-target"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = 30
        matcher             = "200"
        path                = "/health"
        protocol            = "HTTP"
        port                = 3000
          
    }
}