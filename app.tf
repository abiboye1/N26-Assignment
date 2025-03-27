###############################################################################
# App Tier (private subnets)
###############################################################################
data "template_file" "app_userdata" {
  template = <<-EOF
  #!/bin/bash
  # Minimal script, no special message
  # Could run an app or Docker container
  EOF
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "n26-app-lt"
  image_id      = data.aws_ami.amzn2_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data             = base64encode(data.template_file.app_userdata.rendered)

  tags = {
    Name = "n26-app-lt"
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "n26-app-asg"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.private_app_subnets[0].id, aws_subnet.private_app_subnets[1].id]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "n26-app-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
