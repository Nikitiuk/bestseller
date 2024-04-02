### Network ###

resource "aws_vpc" "bestseller_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "bestseller_private_subnet" {
  vpc_id            = aws_vpc.bestseller_vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.availability_zone_private

  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_subnet" "bestseller_public_subnet" {
  vpc_id            = aws_vpc.bestseller_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.availability_zone_public
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_internet_gateway" "bestseller_gw" {
  vpc_id = aws_vpc.bestseller_vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_eip" "nat_eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "bestseller_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.bestseller_public_subnet.id

  tags = {
    Name = "Public NAT"
  }

  # Adding dependency as stated in the official documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
  depends_on = [aws_internet_gateway.bestseller_gw]
}

resource "aws_route_table" "bestseller_private_route_table" {
  vpc_id = aws_vpc.bestseller_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.bestseller_nat_gateway.id
  }

  tags = {
    Name = "Bestseller-Private-Route-Table"
  }
}

resource "aws_route_table_association" "bestseller_private_route_table_association" {
  subnet_id      = aws_subnet.bestseller_private_subnet.id
  route_table_id = aws_route_table.bestseller_private_route_table.id
}

### IAM ###

resource "aws_iam_role" "bestseller_ec2_s3_role" {
  name = "bestseller_ec2_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "bestseller_s3_iam_policy" {
  name        = "bestseller_s3_iam_policy"
  description = "Allows EC2 instances to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Put*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bestseller_ec2_s3_policy_attachment" {
  role       = aws_iam_role.bestseller_ec2_s3_role.name
  policy_arn = aws_iam_policy.bestseller_s3_iam_policy.arn
}

resource "aws_iam_instance_profile" "bestseller_ec2_profile" {
  name = "bestseller_ec2_profile"
  role = aws_iam_role.bestseller_ec2_s3_role.name
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.bestseller_vpc.id

  tags = {
    Name = "allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

### Load Balancer ###

resource "aws_lb" "bestseller_lb" {
  name               = "bestseller-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [aws_subnet.bestseller_private_subnet.id,aws_subnet.bestseller_public_subnet.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "bestseller_tg" {
  name     = "bestseller-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.bestseller_vpc.id
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.bestseller_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bestseller_tg.arn
  }
}

### AutoScale Group ###

# Get the latest AMI version of the Amazon Linux
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_configuration" "bestseller_lc" {
  
  instance_type = var.asg_instance_type
  iam_instance_profile = aws_iam_instance_profile.bestseller_ec2_profile.name
  name_prefix   = "bestseller-lc"
  image_id      = data.aws_ami.amazon_linux.id

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Bestseller Technical assignment</h1>" > /var/www/html/index.html
              EOF
}

resource "aws_autoscaling_group" "bestseller_asg" {
  launch_configuration = aws_launch_configuration.bestseller_lc.name
  min_size             = 1
  max_size             = 3
  vpc_zone_identifier  = [aws_subnet.bestseller_private_subnet.id]
  target_group_arns    = [aws_lb_target_group.bestseller_tg.arn]

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.bestseller_asg.name

  policy_type = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.bestseller_asg.name

  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bestseller_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu-usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bestseller_asg.name
  }
}
