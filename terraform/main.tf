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

  tags = {
    Name = var.private_subnet_name
  }
}

resource "aws_subnet" "bestseller_public_subnet" {
  vpc_id            = aws_vpc.bestseller_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name
  }
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

### EC2 ###

data "aws_ami" "ubuntu_2204" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical's owner ID
}

resource "aws_instance" "bestseller_instance" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.bestseller_private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.bestseller_ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Bestseller Technical assignment</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = var.ec2_name
  }
}