data "aws_lb" "main" {
  name = "main-lb"
}

# Create a new target group with a different name
resource "aws_lb_target_group" "new_main" {
  name     = "new-main-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id
}

data "aws_lb_target_group" "main" {
  name = aws_lb_target_group.new_main.name
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.main.arn
  }
}
