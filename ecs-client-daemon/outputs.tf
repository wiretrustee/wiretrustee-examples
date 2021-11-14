output "ecs_cluster" {
  value = aws_ecs_cluster.wiretrustee.name
}

output "ecs_autoscaling_group" {
  value = aws_autoscaling_group.wiretrustee.name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}