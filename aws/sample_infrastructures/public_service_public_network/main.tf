locals {
  region         = var.region
  name_prefix    = var.name_prefix
  container_name = "${var.name_prefix}-app"
}

### VPC
module "vpc" {
  source = "../../modules/vpc"

  name_prefix               = local.name_prefix
  region                    = local.region
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  cidr_block                = var.vpc_cidr_block
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

module "ecs_instance_sg" {
  source = "../../modules/sg"

  region = local.region
  name   = "${local.name_prefix}-ecs-instance-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [{
    description                  = "Allow incoming TCP connections on port ${var.app_port} from ALB only"
    from_port                    = var.app_port
    ip_protocol                  = "TCP"
    referenced_security_group_id = module.alb_sg.id
    to_port                      = var.app_port
  }]

  egress_rules = [{
    cidr_ipv4   = "0.0.0.0/0"
    description = "Allow all outgoing connections"
    from_port   = 0
    ip_protocol = "ALL"
    to_port     = 0
  }]
}

data "aws_ssm_parameter" "ecs_optimized_ami_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "default" {
  instance_type = "t2.micro"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami_id.value
  user_data     = base64encode("#!/bin/bash\necho ECS_CLUSTER=${module.application_deployment.cluster_name} >> /etc/ecs/ecs.config")

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [module.ecs_instance_sg.id]
  }
}

### ALB
module "alb_sg" {
  source = "../../modules/sg"

  name   = "${local.name_prefix}-alb-sg"
  region = local.region
  vpc_id = module.vpc.vpc_id

  ingress_rules = [{
    cidr_ipv4   = "0.0.0.0/0"
    description = "Allow all incoming HTTP connections"
    from_port   = 80
    ip_protocol = "TCP"
    to_port     = 80
  }]

  egress_rules = [{
    cidr_ipv4   = "0.0.0.0/0"
    description = "Allow all outgoing connections"
    from_port   = 0
    ip_protocol = "ALL"
    to_port     = 0
  }]
}

resource "aws_lb" "main" {
  name               = "${local.name_prefix}-lb"
  load_balancer_type = "application"
  security_groups    = [module.alb_sg.id]
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

module "application_deployment" {
  source = "../../modules/application_deployment"

  name_prefix = local.name_prefix
  region      = local.region
  vpc_id      = module.vpc.vpc_id

  ### ECR
  force_delete = true
  ecs_provider = "EC2"
  asg_arn      = module.asg.asg_arn

  ### ECS TASK DEFINITION
  task_definition_family = "${local.name_prefix}-app"
  task_definition_container_definitions = jsonencode([{
    name      = local.container_name
    essential = true
    cpu       = 256
    memory    = 512

    portMappings = [{
      protocol      = "tcp"
      containerPort = var.app_port
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
  task_definition_network_mode             = "awsvpc"
  task_definition_required_compatibilities = "EC2"

  ### ECS SERVICE
  service_load_balancer = {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = local.container_name
    container_port   = var.app_port
  }
  service_network_configuration = {
    security_groups = [module.ecs_instance_sg.id]
    subnets         = module.vpc.public_subnets_ids
  }
  service_triggers = {
    redeploymenet = timestamp()
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "ecs-logs"
}
