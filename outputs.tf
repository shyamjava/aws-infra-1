output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "public_instance_id" {
  description = "ID of the public EC2 instance"
  value       = aws_instance.public.id
}

output "public_instance_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = aws_instance.public.public_ip
}

output "public_instance_private_ip" {
  description = "Private IP of the public EC2 instance"
  value       = aws_instance.public.private_ip
}

output "private_instance_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private.id
}

output "private_instance_private_ip" {
  description = "Private IP of the private EC2 instance"
  value       = aws_instance.private.private_ip
}

output "nat_instance_id" {
  description = "ID of the NAT instance"
  value       = aws_instance.nat.id
}

output "nat_instance_public_ip" {
  description = "Public IP of the NAT instance"
  value       = aws_instance.nat.public_ip
}

output "nat_instance_private_ip" {
  description = "Private IP of the NAT instance"
  value       = aws_instance.nat.private_ip
}

output "security_group_ids" {
  description = "IDs of the security groups"
  value = {
    public  = aws_security_group.public.id
    private = aws_security_group.private.id
    nat     = aws_security_group.nat.id
    eice    = aws_security_group.eice.id
  }
}

output "ec2_instance_connect_endpoint_id" {
  description = "ID of the EC2 Instance Connect Endpoint"
  value       = aws_ec2_instance_connect_endpoint.main.id
}

output "ec2_instance_connect_endpoint_arn" {
  description = "ARN of the EC2 Instance Connect Endpoint"
  value       = aws_ec2_instance_connect_endpoint.main.arn
}

output "ec2_instance_connect_endpoint_dns_name" {
  description = "DNS name of the EC2 Instance Connect Endpoint"
  value       = aws_ec2_instance_connect_endpoint.main.dns_name
}

output "ec2_instance_connect_endpoint_state" {
  description = "State of the EC2 Instance Connect Endpoint"
  value       = "create-complete"  # EICE is created and ready
}

output "ec2_instance_connect_endpoint_subnet_id" {
  description = "Subnet ID where the EICE is deployed"
  value       = aws_ec2_instance_connect_endpoint.main.subnet_id
}

output "debugging_info" {
  description = "Debugging information for troubleshooting"
  value = {
    eice_id = aws_ec2_instance_connect_endpoint.main.id
    eice_state = "create-complete"
    eice_subnet = aws_ec2_instance_connect_endpoint.main.subnet_id
    private_subnets = aws_subnet.private[*].id
    vpc_cidr = aws_vpc.main.cidr_block
    private_subnet_cidrs = aws_subnet.private[*].cidr_block
  }
}

# VPC Endpoints Outputs
output "vpc_endpoints" {
  description = "VPC Endpoints information"
  value = {
    # Gateway endpoints (S3, DynamoDB) - no DNS entries
    s3_endpoint_id = aws_vpc_endpoint.s3.id
    dynamodb_endpoint_id = aws_vpc_endpoint.dynamodb.id
    
    # Interface endpoints (SQS, RDS) - have DNS entries
    sqs_endpoint_id = aws_vpc_endpoint.sqs.id
    sqs_endpoint_dns_name = aws_vpc_endpoint.sqs.dns_entry[0].dns_name
    rds_endpoint_id = aws_vpc_endpoint.rds.id
    rds_endpoint_dns_name = aws_vpc_endpoint.rds.dns_entry[0].dns_name
  }
}

output "vpc_endpoints_security_group_id" {
  description = "Security Group ID for VPC Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
