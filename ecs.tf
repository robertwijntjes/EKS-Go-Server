resource "aws_ecs_cluster" "p_ecs_cluster" {
  name = "personio-ecs-cluster" # Naming the cluster
}



resource "aws_ecs_task_definition" "personio-server-task-def" {
  family                   = "personio-server-task-def" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "personio-server-task-def",
      "image": "${aws_ecr_repository.my_first_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_ecs_service" "personio-server-service" {
  name            = "personio-server-service"   
  cluster         = "${aws_ecs_cluster.p_ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.personio-server-task-def.arn}" 
  launch_type     = "FARGATE"
  desired_count   = 2 # Setting the number of containers we want deployed to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.personio-server-task-def.family}"
    container_port   = 8080 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}","${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
}

