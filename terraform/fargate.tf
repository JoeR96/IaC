data "aws_ssm_parameter" "ecr_repository_url" {
  name = "/app/cognito-auth-api/url"
}

resource "aws_security_group" "fargate" {
  name        = "fargate_security_group"
  description = "Fargate security group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "fargate_ingress" {
  security_group_id = aws_security_group.fargate.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_ecs_cluster" "main" {
  name = "main-ecs-cluster"
}

data "aws_iam_role" "existing_ecs_task_execution_role" {
  name = "my-ecs-task-execution-role"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = data.aws_iam_role.existing_ecs_task_execution_role.name
}

resource "aws_ecs_task_definition" "main" {
  family                   = "your_task_family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.existing_ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "cognito-auth-api"
      image = data.aws_ssm_parameter.ecr_repository_url.value
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      essential = true
    }
    # Add more container definitions here as needed, up to 10 containers
  ])
}

resource "aws_ecs_service" "main" {
  name            = "main-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.main.id, aws_subnet.secondary.id]
    security_groups  = [aws_security_group.fargate.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.main.arn
    container_name   = "cognito-auth-api"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.main
  ]
}
