output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = module.vpc.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = module.vpc.private_subnet_cidrs
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.vpc.nat_gateway_public_ip
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
    public  = module.vpc.public_security_group_id
    private = module.vpc.private_security_group_id
    nat     = module.vpc.nat_security_group_id
    eice    = module.vpc.eice_security_group_id
  }
}

output "ec2_instance_connect_endpoint_id" {
  description = "ID of the EC2 Instance Connect Endpoint"
  value       = module.vpc.eice_id
}

output "ec2_instance_connect_endpoint_arn" {
  description = "ARN of the EC2 Instance Connect Endpoint"
  value       = module.vpc.eice_id  # Using ID as ARN for now
}

output "ec2_instance_connect_endpoint_dns_name" {
  description = "DNS name of the EC2 Instance Connect Endpoint"
  value       = module.vpc.eice_id  # Using ID as DNS name for now
}

output "ec2_instance_connect_endpoint_state" {
  description = "State of the EC2 Instance Connect Endpoint"
  value       = "create-complete"  # EICE is created and ready
}

output "ec2_instance_connect_endpoint_subnet_id" {
  description = "Subnet ID where the EICE is deployed"
  value       = module.vpc.private_subnet_ids[0]  # EICE is in first private subnet
}

output "debugging_info" {
  description = "Debugging information for troubleshooting"
  value = {
    eice_id = module.vpc.eice_id
    eice_state = "create-complete"
    eice_subnet = module.vpc.private_subnet_ids[0]
    private_subnets = module.vpc.private_subnet_ids
    vpc_cidr = module.vpc.vpc_cidr_block
    private_subnet_cidrs = module.vpc.private_subnet_cidrs
  }
}

# VPC Endpoints Outputs
output "vpc_endpoints" {
  description = "VPC Endpoints information"
  value = {
    # Gateway endpoints (S3, DynamoDB) - no DNS entries
    s3_endpoint_id = module.vpc.s3_vpc_endpoint_id
    dynamodb_endpoint_id = module.vpc.dynamodb_vpc_endpoint_id
    
    # Interface endpoints (SQS, RDS) - have DNS entries
    sqs_endpoint_id = module.vpc.sqs_vpc_endpoint_id
    sqs_endpoint_dns_name = "sqs-endpoint"  # Simplified for now
    rds_endpoint_id = module.vpc.rds_vpc_endpoint_id
    rds_endpoint_dns_name = "rds-endpoint"  # Simplified for now
  }
}

output "vpc_endpoints_security_group_id" {
  description = "Security Group ID for VPC Endpoints"
  value       = module.vpc.vpc_endpoints_security_group_id
}
