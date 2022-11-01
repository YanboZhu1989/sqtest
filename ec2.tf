/* data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_launch_template" "apptier" {
  name = "apptier"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ecr_connection.name
  }



  instance_type = "t2.micro"
  image_id      = data.aws_ami.amazon_linux_2.id

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.backend_apptier.id]
  }

  placement {
    availability_zone = "ap-southeast-2"
  }

  depends_on = [
    aws_nat_gateway.ngw
  ]
}

resource "aws_autoscaling_group" "apptier" {
  name                      = "launchTemplate-ASG-apptier"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 3
  vpc_zone_identifier       = aws_subnet.private_subnets.*.id

  launch_template {
    id      = aws_launch_template.apptier.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  tag {
    key                 = "Name"
    value               = "apptier"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "apptier" {
  autoscaling_group_name = aws_autoscaling_group.apptier.id
  lb_target_group_arn    = aws_lb_target_group.apptier.arn
} */

