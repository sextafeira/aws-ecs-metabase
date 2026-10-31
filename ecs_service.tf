resource "aws_ecs_service" "main" {
  name                               = var.project_name
  cluster                            = aws_ecs_cluster.metabase.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.metabase_task_desired
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  health_check_grace_period_seconds  = 600
  enable_ecs_managed_tags            = true
  propagate_tags                     = "SERVICE"
  wait_for_steady_state              = true
  lifecycle {
    ignore_changes = [task_definition]
  }
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 1
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  network_configuration {
    subnets         = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]
    security_groups = [aws_security_group.ecs_task.id]
  }
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "metabase"
    container_port   = 3000
  }
  depends_on = [
    aws_ecs_cluster_capacity_providers.metabase,
    aws_lb_listener.https,
    aws_vpc_security_group_egress_rule.task_to_rds,
    aws_vpc_security_group_egress_rule.task_http,
    aws_vpc_security_group_egress_rule.task_https,
    aws_vpc_security_group_ingress_rule.rds_from_task,
    aws_vpc_security_group_ingress_rule.task_from_alb,
    aws_vpc_security_group_egress_rule.alb_to_task
  ]

  tags = {
    Name        = var.project_name
    Environment = var.environment
    Terraform   = "True"
  }
}
