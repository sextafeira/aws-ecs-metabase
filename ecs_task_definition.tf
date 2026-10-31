resource "aws_ecs_task_definition" "main" {
  family                   = format("%s-main", var.project_name)
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([{
    name         = "metabase"
    image        = format("%s:%s", aws_ecr_repository.metabase.repository_url, var.image_tag)
    essential    = true
    cpu          = var.main_cpu
    memory       = var.main_memory
    stopTimeout  = 120
    portMappings = [{ containerPort = 3000, hostPort = 3000, protocol = "tcp" }]
    environment = [
      { name = "MB_DB_TYPE", value = "postgres" },
      { name = "MB_DB_HOST", value = aws_db_instance.metabase.address },
      { name = "MB_DB_PORT", value = "5432" },
      { name = "MB_DB_DBNAME", value = var.db_name },
      { name = "MB_DB_USER", value = var.db_username },
      { name = "MB_DB_AWS_IAM", value = "true" },
      { name = "MB_DB_CONNECTION_URI", value = format("jdbc:postgresql://%s:5432/%s?sslmode=verify-full&sslrootcert=/opt/certs/global-bundle.pem", aws_db_instance.metabase.address, var.db_name) },
      { name = "MB_SITE_URL", value = format("https://%s", var.domain_name) },
      { name = "JAVA_OPTS", value = "-Xms512m -Xmx1024m" },
      { name = "AWS_REGION", value = var.region },
      { name = "MB_LOAD_SAMPLE_CONTENT", value = "false" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "metabase"
      }
    }
    linuxParameters = { initProcessEnabled = true }
  }])
  depends_on = [aws_iam_role_policy_attachment.ecs_execution, aws_iam_role_policy.rds_connect]
  tags = {
    Name        = format("%s-main", var.project_name)
    Environment = var.environment
    Terraform   = "True"
  }
}
