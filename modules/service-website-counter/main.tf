resource "aws_cloudwatch_log_group" "service_website_counter" {
  name              = "service_website_counter"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "service_website_counter" {
  family = "service_website_counter"

  container_definitions = <<EOF
[
  {
    "name": "service_website_counter",
    "image": "517586233148.dkr.ecr.us-east-1.amazonaws.com/counter:latest",
    "cpu": 1,
    "memory": 128,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-1",
        "awslogs-group": "service_website_counter",
        "awslogs-stream-prefix": "complete-ecs"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "service_website_counter" {
  name            = "service_website_counter"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.service_website_counter.arn

  desired_count = 1
  iam_role = AmazonDynamoDBFullAccess
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}