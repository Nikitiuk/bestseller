### Network ###

variable "availability_zone_private" {
  type = string
  description = "The Availability Zone for private network resources"
  default = "eu-central-1a"
}

variable "availability_zone_public" {
  type = string
  description = "The Availability Zone for public network resources"
  default = "eu-central-1c"
}

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

variable "internet_gateway_name" {
  type = string
  description = "Internet Gateway's name"
  default = "Bestseller_gw"
}

### AutoScale Group ###

variable "asg_instance_type" {
  type = string
  description = "Instance type used on ASG"
  default = "t2.micro"
}

variable "asg_name" {
  type = string
  description = "ASG instance's name"
  default = "Bestseller-ASG-Instance"
}