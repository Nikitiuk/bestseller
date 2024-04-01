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