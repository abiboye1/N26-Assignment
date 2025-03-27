###############################################################################
# ALB + WAF (already declared in main.tf if you prefer)
###############################################################################
resource "aws_lb" "app_alb" {
  name               = "n26-app-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]

  tags = {
    Name = "n26-app-alb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name        = "n26-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    path     = "/"
    matcher  = "200"
  }

  tags = {
    Name = "n26-web-tg"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  tags = {
    Name = "n26-alb-listener"
  }
}

# WAF v2 Web ACL
resource "aws_wafv2_web_acl" "web_acl" {
  name        = "n26-web-acl"
  description = "Basic WAF for ALB"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "commonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "n26WebAcl"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "n26-waf-web-acl"
  }
}

resource "aws_wafv2_web_acl_association" "acl_assoc" {
  resource_arn = aws_lb.app_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}

###############################################################################
# Web Server ASG (in public subnets)
###############################################################################
data "aws_ami" "amzn2_linux" {
  most_recent = true
  owners      = ["amazon"] 

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "template_file" "web_userdata" {
  template = <<-EOF
  #!/bin/bash
  yum install -y httpd
  echo "<html><body><h1>Hello Abib! Welcome to N26 </h1></body></html>" > /var/www/html/index.html
  systemctl enable httpd
  systemctl start httpd
  EOF
}

resource "aws_launch_template" "web_lt" {
  name_prefix   = "n26-web-lt"
  image_id      = data.aws_ami.amzn2_linux.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.generated.key_name

  # The IAM instance profile
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_connect_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(data.template_file.web_userdata.rendered)

  tags = {
    Name = "n26-web-lt"
  }
}



resource "aws_autoscaling_group" "web_asg" {
  name                = "n26-web-asg"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]

  tag {
    key                 = "Name"
    value               = "n26-web-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
