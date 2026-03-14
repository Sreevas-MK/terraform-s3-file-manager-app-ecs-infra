module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${var.project_name}-${var.project_env}-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${var.project_name}"
      }
    }
  }

  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = {
    FARGATE      = { weight = 50, base = 1 }
    FARGATE_SPOT = { weight = 50 }
  }

  services = {
    s3node-app = {
      cpu           = 512  # per-task CPU
      memory        = 1024 # per-task memory
      desired_count = 2    # initial number of tasks

      force_new_deployment = true

      task_exec_iam_role_arn = aws_iam_role.ecs_task_execution_role.arn
      tasks_iam_role_arn     = aws_iam_role.ecs_iam_role.arn

      create_tasks_iam_role     = false
      create_task_exec_iam_role = false

      container_definitions = {
        app = {
          image     = "${data.aws_ecr_repository.app_repo.repository_url}:latest"
          essential = true
          portMappings = [
            {
              containerPort = 3000
              protocol      = "tcp"
            }
          ]
          environment = [
            { name = "AWS_REGION", value = var.aws_region },
            { name = "S3_BUCKET_NAME", value = var.app_bucket_name }
          ]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = aws_lb_target_group.s3_app_tg.arn
          container_name   = "app"
          container_port   = 3000
        }
      }

      subnet_ids            = aws_subnet.private_subnets[*].id
      security_group_ids    = [aws_security_group.ecs.id]
      create_security_group = false

      # Auto Scaling
      scaling_policies = {
        cpu = {
          policy_name        = "cpu-scaling"
          metric_type        = "ECSServiceAverageCPUUtilization"
          target_value       = 75.0
          scale_in_cooldown  = 60
          scale_out_cooldown = 60
          min_capacity       = 1
          max_capacity       = 4
        }
        memory = {
          policy_name        = "mem-scaling"
          metric_type        = "ECSServiceAverageMemoryUtilization"
          target_value       = 75.0
          scale_in_cooldown  = 60
          scale_out_cooldown = 60
          min_capacity       = 1
          max_capacity       = 4
        }
      }
    }
  }

  tags = {
    Environment = var.project_env
    Project     = var.project_name
    Owner       = var.project_owner
  }
}
