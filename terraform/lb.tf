data "aws_lb" "main" {
  name = "main-lb"
}

data "aws_lb_target_group" "main" {
  name = "main-tg"
}

# Remove the "aws_lb" and "aws_lb_target_group" resource blocks from lb.tf

resource "aws_lb_listener" "main" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.main.arn
  }
}
