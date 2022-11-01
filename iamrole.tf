resource "aws_iam_role" "ecs_task_role" {
  name               = "allow-ecs-access"
  path               = "/"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
                {
                "Action": "sts:AssumeRole",
                "Principal": {"Service": "ecs-tasks.amazonaws.com"                },
                "Effect": "Allow",
                "Sid": ""
                }
        ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_ecr_connection" {
  name = "ecs-ecr-connection"
  role = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role_policy" "access_ecr_policy" {
  name = "allow-ecs-access-ecr"
  role = aws_iam_role.ecs_task_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : ["ecr:*"],
        "Resource" : "*"
      }
    ]
  })

}

/* resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = tostring(aws_iam_role_policy.access_ecr_policy.id)
} */

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}