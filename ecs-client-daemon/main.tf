# VPC

data "aws_region" "current" {}

locals {
  az_a = format("%sa",data.aws_region.current.name)
  az_b = format("%sb",data.aws_region.current.name)
  az_c = format("%sc",data.aws_region.current.name)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.vpc_cidr

  azs             = [local.az_a, local.az_b]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  # for the sake of costs
  single_nat_gateway = true

}

# ECS resources
resource "aws_ecs_cluster" "wiretrustee" {
    name = var.name
}

resource "aws_ecs_service" "wiretrustee" {
  name                = var.name
  cluster             = aws_ecs_cluster.wiretrustee.id
  task_definition     = aws_ecs_task_definition.wiretrustee.arn
  scheduling_strategy = "DAEMON"
}

resource "aws_ecs_task_definition" "wiretrustee" {
  family = var.name
  container_definitions = jsonencode([
    {
      name      = var.name
      image     = "wiretrustee/wiretrustee:0.2.3-SNAPSHOT-95ef854-amd64"
      essential = true
      memoryReservation = 64
      privileged = true
      environment = [
        {
          name = "WT_LOG_FILE"
          value = "console"
        },
        {
          name = "WT_LOG_LEVEL"
          value = var.wt_log_level
        },
        {
          name = "WT_SETUP_KEY"
          value = var.wt_setup_key
        }
      ]
      mountPoints = [
        {
          containerPath = "/etc/wiretrustee"
          sourceVolume = var.name
        }
      ]}
    ])
  network_mode = "host"
  volume {
      name      = var.name
      host_path = "/etc/wiretrustee"
  }
}

# EC2 resources

data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

data "aws_iam_policy_document" "ecs_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

locals {
  userdata = <<-USERDATA
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.wiretrustee.name}" >> /etc/ecs/ecs.config
  USERDATA
}

resource "aws_iam_role" "ecs" {
      assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
      managed_policy_arns = [
          "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
      name_prefix = var.name
}

resource "aws_iam_instance_profile" "ecs" {
        role = aws_iam_role.ecs.name
        name_prefix = var.name
}

resource "aws_key_pair" "ecs" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

resource "aws_launch_template" "wiretrustee" {
    name_prefix = var.name
    image_id = data.aws_ami.ecs.image_id
    instance_type = var.instance_type
    iam_instance_profile {
        name = aws_iam_instance_profile.ecs.name
    }
    key_name = aws_key_pair.ecs.key_name
    vpc_security_group_ids = [
        module.vpc.default_security_group_id
    ]
    user_data = base64encode(local.userdata)
}

data "aws_default_tags" "wiretrustee" {}


resource "aws_autoscaling_group" "wiretrustee" {
    name_prefix = var.name
    desired_capacity = 1
    max_size = 2
    min_size = 0
    vpc_zone_identifier = module.vpc.private_subnets
    launch_template {
      id = aws_launch_template.wiretrustee.id
      version = "$Latest"
    }
    dynamic "tag" {
        for_each = data.aws_default_tags.wiretrustee.tags
        content {
            key                 = tag.key
            value               = tag.value
            propagate_at_launch = true
        }
    }
}

