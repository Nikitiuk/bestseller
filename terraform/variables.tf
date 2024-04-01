### Network ###

variable "vpc_cidr_block" {
  type = string
  description = "VPC's IP range"
  default = "10.10.0.0/16"
}

variable "private_subnet_cidr_block" {
  type = string
  description = "Private subnet's IP range"
  default = "10.10.1.0/24"
}

variable "public_subnet_cidr_block" {
  type = string
  description = "Public subnet's IP range"
  default = "10.10.2.0/24"
}

variable "vpc_name" {
  type = string
  description = "VPC's name"
  default = "Bestseller_vpc"
}

variable "private_subnet_name" {
  type = string
  description = "Private subnet's name"
  default = "Bestseller_private_subnet"
}

variable "public_subnet_name" {
  type = string
  description = "Public subnet's name"
  default = "Bestseller_public_subnet"
}

### EC2 ###

variable "ec2_instance_type" {
  type = string
  description = "EC2 instance type"
  default = "t2.micro"
}

variable "ec2_name" {
  type = string
  description = "EC2's name"
  default = "Bestseller-Instance"
}