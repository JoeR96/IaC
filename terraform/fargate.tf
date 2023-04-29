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

resource "aws_ecs_task_definition" "main" {
  family                   = "your_task_family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role[0].arn

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role[0].name
}

data "aws_iam_role" "existing_ecs_task_execution_role" {
  name = "my-ecs-task-execution-role"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  count = data.aws_iam_role.existing_ecs_task_execution_role.id == "" ? 1 : 0
  name = "my-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}