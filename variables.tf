variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
}

variable "nat_ami_id" {
  description = "AMI ID for NAT instance"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "nat_instance_type" {
  description = "Instance type for NAT instance"
  type        = string
  default     = "t2.nano"
}

