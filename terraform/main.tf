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
