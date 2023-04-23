terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  region      = var.region
  name_prefix = var.name_prefix
}

provider "aws" {
  region = local.region
}

### VPC
module "vpc" {
  source = "../../modules/vpc"

  name_prefix               = local.name_prefix
  region                    = local.region
  public_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
}

### ASG
module "asg" {
  source = "../../modules/asg"

  name_prefix        = local.name_prefix
  region             = local.region
  subnet_ids         = module.vpc.public_subnets_ids
  max_size           = 2
  launch_template_id = aws_launch_template.default.id
}

### EC2 LAUNCH TEMPLATE
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "${local.name_prefix}-ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Policy to allow EC2 to perform the required actions
resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "${local.name_prefix}-ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_security_group" "ecs_instances" {
  name   = "${local.name_prefix}-ecs-instance-sg"
  vpc_id = module.vpc.vpc_id

  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow incoming TCP connections on port 80 from ALB only"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "ALL"
    security_groups  = []
    self             = false
    to_port          = 0
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outgoing connections"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "ALL"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
}

data "aws_ssm_parameter" "ecs_optimized_ami_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "default" {
  instance_type = "t2.micro"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami_id.value
  user_data     = base64encode("#!/bin/bash\necho ECS_CLUSTER=${module.ecs.cluster_name} >> /etc/ecs/ecs.config")

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs_instances.id]
  }
}

### ECR
resource "aws_ecr_repository" "main" {
  name         = "${local.name_prefix}-ecr-main"
  force_delete = true
}

### ALB
resource "aws_security_group" "alb" {
  name   = "${local.name_prefix}-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all incoming connections"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "TCP"
    security_groups  = []
    self             = false
    to_port          = 80
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outgoing connections"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "ALL"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
}

resource "aws_lb" "main" {
  name               = "${local.name_prefix}-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_instances.id]
  subnets            = module.vpc.public_subnets_ids
}

resource "aws_lb_target_group" "main" {
  name        = "${local.name_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.main.id
    type             = "forward"
  }
}

### ECS
module "ecs" {
  source = "../../modules/ecs"

  name_prefix  = local.name_prefix
  region       = local.region
  vpc_id       = module.vpc.vpc_id
  asg_arn      = module.asg.asg_arn
  cluster_name = "default"
  ecs_provider = "EC2"
}

# Task definition using EC2 instances
resource "aws_ecs_task_definition" "default" {
  family                   = "${local.name_prefix}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([{
    name  = "${local.name_prefix}-app"
    image = "${aws_ecr_repository.main.repository_url}:latest"
    # image     = "registry.gitlab.com/architect-io/artifacts/nodejs-hello-world:latest"
    essential = true
    cpu       = 256
    memory    = 512

    portMappings = [{
      protocol      = "tcp"
      containerPort = 80
    }]

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name,
        awslogs-region        = local.region,
        awslogs-stream-prefix = "${local.name_prefix}-ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "default" {
  name            = "${local.name_prefix}-ecs-service"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = 1

  network_configuration {
    security_groups = [aws_security_group.ecs_instances.id]
    subnets         = module.vpc.public_subnets_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "${local.name_prefix}-app"
    container_port   = 80
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "ecs-logs"
}
