data "aws_ecr_repository" "testapp" {
  name = "testapp"
}
resource "aws_cloudwatch_log_group""logGroup" {
  name = "ECS-logs"
  }

resource "aws_ecs_cluster" "main" {
  name = "junglemeet-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration{
      logging    = "OVERRIDE"
      
      log_configuration {
        cloud_watch_encryption_enabled = true

        cloud_watch_log_group_name     = aws_cloudwatch_log_group.logGroup.name
      }
    }      
    
  }
}


resource "aws_ecs_task_definition" "main-app" {
  family                   = "main-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name      = "MyTestApp"
    image     = "${data.aws_ecr_repository.testapp.repository_url}:v_16"
    essential = true
    //environment = var.container_environment
    portMappings = [{
      protocol      = "HTTP"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
  }])
}

resource "aws_ecs_service" "main" {
  name                               = "junglemeet-ecs-servicce"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main-app.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 20
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups = [aws_security_group.ecsTasks.id]
    subnets         = aws_subnet.private_subnets.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.apptier.arn
    container_name   = "MyTestApp"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_memory" {
  name               = "ecs-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "ecs-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}