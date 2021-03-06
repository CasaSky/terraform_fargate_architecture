locals {
  container_definitions = "[${jsonencode({
    name             = var.webservice_name
    image            = aws_ecr_repository.ecs.repository_url
    cpu              = 0
    essential        = local.essential
    portMappings     = local.port_mappings
    environment      = local.environment
    logConfiguration = local.log_configuration
    mountPoints      = []
    volumesFrom      = []
  })}]"

  cpu = 256
  memory = 512
  essential = true

  # todo figure out a way to manage multiple environments (test, prod)
  environment = []

  port_mappings = [{
    containerPort = 9090
    hostPort = 9090
    protocol = "tcp"
  }]

  log_configuration = {
    logDriver = "awslogs",
    options = {
      awslogs-group         = format("/ecs/%s", local.family)
      awslogs-region        = "eu-central-1"
      awslogs-stream-prefix = "ecs"
    }
  }

  family = format("%s-fg-task-def", var.webservice_name)
}

locals {
  www_cidr_block = "0.0.0.0/0"
}

module "alb_certificate" {
  source = "../../modules/cert/"
  domain_name = format("%s.alb.%s", var.webservice_name, var.primary_zone_name)
  validation_method = "DNS"
  tags = {
    application = var.webservice_name
  }
  primary_zone_id = var.primary_zone_id
}

resource "aws_security_group" "service" {
  vpc_id      = var.vpc_id
  name        = format("%s-fg-sg", var.webservice_name)
  description = "fargate sg"

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "provisory (change to local net or fix ip)"
    from_port        = 22
    protocol         = "tcp"
    to_port          = 22
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 0
    protocol         = "-1"
    self             = false
    to_port          = 0
  }
}

resource "aws_security_group" "alb" {
  vpc_id      = var.vpc_id
  name        = format("%s-fg-alb-sg", var.webservice_name)
  description = "sg for alb"

  ingress {
    cidr_blocks      = [local.www_cidr_block]
    from_port        = 80
    protocol         = "tcp"
    to_port          = 80
  }

  ingress {
    cidr_blocks      = [local.www_cidr_block]
    from_port        = 443
    protocol         = "tcp"
    to_port          = 443
  }

  egress {
    cidr_blocks      = [local.www_cidr_block]
    from_port        = 0
    protocol         = "-1"
    self             = false
    to_port          = 0
  }
}

resource "aws_lb" "service" {
  name               = format("%s-fg-alb", var.webservice_name)
  load_balancer_type = "application"
  security_groups    = [var.default_sg_id, aws_security_group.alb.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "alb" {
  name     = format("%s-fg-alb-tg", var.webservice_name)
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id
  depends_on = [aws_lb.service]
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.service.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

resource "aws_lb_listener" "ssl_alb" {
  load_balancer_arn = aws_lb.service.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.alb_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

# This resource is for additional certificates and does not replace the default certificate on the listener.
resource "aws_lb_listener_certificate" "ssl_alb" {
  listener_arn    = aws_lb_listener.ssl_alb.arn
  certificate_arn = module.alb_certificate.arn
}

resource "aws_iam_role" "task_definition" {
  name = format("%s-fg-task-def-role", var.webservice_name)
  description = "Allows ECS tasks to call AWS services on your behalf."

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "ecs" {
  family                = local.family
  container_definitions = local.container_definitions
  cpu                   = local.cpu
  memory                = local.memory
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn      = aws_iam_role.task_definition.arn
  execution_role_arn = data.aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecr_repository" "ecs" {
  name = var.webservice_name
}

resource "aws_ecs_cluster" "ecs" {
  name = format("%s-fg-cluster", var.webservice_name)
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  setting {
    name = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "ecs" {
  name            = format("%s-fg-service", var.webservice_name)
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = format("%s:%s", aws_ecs_task_definition.ecs.id, max(aws_ecs_task_definition.ecs.revision))
  desired_count   = 1
  depends_on      = [data.aws_iam_role.ecsTaskExecutionRole]
  enable_ecs_managed_tags = true
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = var.webservice_name
    container_port   = 9090
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [aws_security_group.service.id, var.default_sg_id]
    subnets = [var.subnet_ids[0]]
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = format("/ecs/%s", aws_ecs_task_definition.ecs.id)

  tags = {
    Name = var.webservice_name
  }
}

resource "aws_route53_record" "alb" {
  zone_id = var.primary_zone_id
  name    = format("%s.alb", var.webservice_name)
  type    = "A"

  alias {
    name                   = aws_lb.service.dns_name
    zone_id                = aws_lb.service.zone_id
    evaluate_target_health = true
  }
}