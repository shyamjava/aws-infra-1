# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Type = "Private"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]
}

# Security Group for Public EC2 (Web Server)
resource "aws_security_group" "public" {
  name_prefix = "${var.project_name}-public-sg"
  vpc_id      = aws_vpc.main.id

  # SSH access from anywhere (for EC2 Instance Connect)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from anywhere"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from anywhere"
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access from anywhere"
  }

  # EC2 Instance Connect - SSH over HTTPS (port 443) from EICE
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eice.id]
    description     = "EC2 Instance Connect from EICE"
  }

  # SSH access from EICE
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eice.id]
    description     = "SSH from EICE"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-public-sg"
  }
}

# Security Group for Private EC2 (NAT Instance)
resource "aws_security_group" "private" {
  name_prefix = "${var.project_name}-private-sg"
  vpc_id      = aws_vpc.main.id

  # SSH access from VPC and EICE
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    description     = "SSH from VPC"
  }

  # HTTP access from VPC
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    description     = "HTTP from VPC"
  }

  # HTTPS access from VPC
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    description     = "HTTPS from VPC"
  }

  # EC2 Instance Connect - SSH over HTTPS (port 443)
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eice.id]
    description     = "EC2 Instance Connect from EICE"
  }

  # SSH access from EICE
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eice.id]
    description     = "SSH from EICE"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-private-sg"
  }
}

# Security Group for NAT Instance
resource "aws_security_group" "nat" {
  name_prefix = "${var.project_name}-nat-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidrs[0], var.private_subnet_cidrs[1]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-nat-sg"
  }
}

# Security Group for EC2 Instance Connect Endpoint
resource "aws_security_group" "eice" {
  name_prefix = "${var.project_name}-eice-sg"
  vpc_id      = aws_vpc.main.id

  # HTTPS access from anywhere (required for EC2 Instance Connect)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for EC2 Instance Connect from internet"
  }

  # Allow outbound HTTPS to AWS services
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to AWS services"
  }

  # Allow outbound HTTP for package updates
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for package updates"
  }

  # Allow outbound SSH to instances in VPC
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SSH to instances in VPC"
  }

  # Allow outbound SSH to specific private subnets
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidrs[0], var.private_subnet_cidrs[1]]
    description = "SSH to private subnet instances"
  }

  # Allow outbound DNS
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "DNS queries"
  }

  # Allow all outbound traffic to VPC (for EC2 Instance Connect)
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "All TCP traffic to VPC for EC2 Instance Connect"
  }

  tags = {
    Name = "${var.project_name}-eice-sg"
  }
}

# EC2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = aws_subnet.private[0].id
  security_group_ids = [aws_security_group.eice.id]
  preserve_client_ip = true

  tags = {
    Name = "${var.project_name}-eice"
  }

  depends_on = [
    aws_route_table_association.private,
    aws_nat_gateway.main
  ]
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project_name}-vpc-endpoints-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-vpc-endpoints-sg"
  }
}

# VPC Endpoint for S3 (Gateway endpoint)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.project_name}-s3-endpoint"
  }
}

# VPC Endpoint for SQS (Interface endpoint)
resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-sqs-endpoint"
  }
}

# VPC Endpoint for DynamoDB (Gateway endpoint)
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.project_name}-dynamodb-endpoint"
  }
}

# VPC Endpoint for RDS (Interface endpoint)
resource "aws_vpc_endpoint" "rds" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.rds"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-rds-endpoint"
  }
}
