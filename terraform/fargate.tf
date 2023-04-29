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

resource "aws_ecr_repository" "cognito_auth_api" {
  name = "cognito-auth-api"
}

resource "aws_ecs_cluster" "main" {
  name = "main-ecs-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "your_task_family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "your_execution_role_arn"

  container_definitions = jsonencode([
    {
      name  = "cognito-auth-api"
      image = "${aws_ecr_repository.cognito_auth_api.repository_url}:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      essential = true
    },
    {
      name  = "container-2"
      image = "your_image_repository_for_container_2"
      portMappings = [
        {
          containerPort = 81
          hostPort      = 81
        }
      ]
      essential = true
    }
    # Add more container definitions here as needed, up to 10 containers
  ])
}
