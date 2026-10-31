output "url" {
  value = format("https://%s", var.domain_name)
}

output "ecr_repository_url" {
  value = aws_ecr_repository.metabase.repository_url
}

output "cluster_name" {
  value = aws_ecs_cluster.metabase.name
}

output "private_subnets" {
  value = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]
}

output "task_security_group" {
  value = aws_security_group.ecs_task.id
}

output "name_servers" {
  value = aws_route53_zone.metabase.name_servers
}

output "connection_arn" {
  value = aws_codeconnections_connection.github.arn
}

output "metabase_version" {
  value = var.metabase_version
}

output "rds_endpoint" {
  value = aws_db_instance.metabase.address
}

output "db_name" {
  value = var.db_name
}

output "db_username" {
  value = var.db_username
}

output "db_master_secret_arn" {
  value = aws_db_instance.metabase.master_user_secret[0].secret_arn
}

output "pipeline_name" {
  value = aws_codepipeline.metabase.name
}
