# Terraform VPC Infrastructure

This Terraform configuration creates a complete VPC infrastructure with public and private subnets across multiple availability zones, including EC2 instances and a NAT instance for private subnet internet access.

## Architecture

The infrastructure includes:

- **VPC**: Custom VPC with DNS support
- **Public Subnets**: 2 public subnets across different AZs with internet gateway access
- **Private Subnets**: 2 private subnets across different AZs with NAT gateway access
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet internet access
- **Route Tables**: Separate routing for public and private subnets
- **Security Groups**: Appropriate security rules for different instance types
- **IAM Roles**: EC2 Instance Connect roles for secure SSH access
- **EC2 Instance Connect Endpoint**: Private endpoint for secure instance access
- **VPC Endpoints**: Private connectivity to AWS services (S3, SQS, DynamoDB, RDS)
- **EC2 Instances**:
  - 1 public instance (web server) in public subnet
  - 1 private instance (application server) in private subnet
  - 1 NAT instance for private subnet internet access

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **AWS Console access** for EC2 Instance Connect (no SSH keys required)

## Quick Start

1. **Clone and navigate to the directory**:
   ```bash
   cd /Users/shyam/work/esl-infra
   ```

2. **Copy the example variables file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit terraform.tfvars** with your specific values (optional):
   ```bash
   nano terraform.tfvars
   ```
   
   **Note**: This configuration uses EC2 Instance Connect, so no SSH keys are required.

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Plan the deployment**:
   ```bash
   terraform plan
   ```

6. **Apply the configuration**:
   ```bash
   terraform apply -auto-approve
   ```

7. **Access your instances**:
   - **Public instance**: SSH using the public IP from outputs
   - **Private instance**: SSH through the public instance (bastion host pattern)

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region | `us-east-1` | No |
| `project_name` | Project name for resource naming | `terraform-vpc` | No |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` | No |
| `public_subnet_cidrs` | Public subnet CIDR blocks | `["10.0.1.0/24", "10.0.2.0/24"]` | No |
| `private_subnet_cidrs` | Private subnet CIDR blocks | `["10.0.3.0/24", "10.0.4.0/24"]` | No |
| `ami_id` | AMI ID for EC2 instances | `ami-0c02fb55956c7d316` | No |
| `nat_ami_id` | AMI ID for NAT instance | `ami-0c02fb55956c7d316` | No |
| `instance_type` | EC2 instance type | `t2.micro` | No |
| `nat_instance_type` | NAT instance type | `t2.nano` | No |

### Customization

You can customize the infrastructure by modifying the `terraform.tfvars` file:

```hcl
# Example custom configuration
aws_region = "us-west-2"
project_name = "my-custom-vpc"
vpc_cidr = "172.16.0.0/16"
public_subnet_cidrs = ["172.16.1.0/24", "172.16.2.0/24"]
private_subnet_cidrs = ["172.16.3.0/24", "172.16.4.0/24"]
instance_type = "t3.small"
```

## Outputs

After deployment, Terraform will output important information:

- **VPC ID**: ID of the created VPC
- **Subnet IDs**: IDs of all created subnets
- **Instance IPs**: Public and private IPs of all instances
- **Security Group IDs**: IDs of created security groups

## Security Groups

### Public Security Group
- **SSH (22)**: From anywhere (0.0.0.0/0)
- **HTTP (80)**: From anywhere (0.0.0.0/0)
- **HTTPS (443)**: From anywhere (0.0.0.0/0)

### Private Security Group
- **SSH (22)**: From VPC CIDR only
- **HTTP (80)**: From VPC CIDR only
- **HTTPS (443)**: From VPC CIDR only

### NAT Security Group
- **All TCP**: From private subnets only
- **All outbound**: To anywhere

### VPC Endpoints Security Group
- **HTTPS (443)**: From VPC CIDR only
- **All outbound**: To anywhere

## Accessing Instances

This infrastructure uses **EC2 Instance Connect** with an **EC2 Instance Connect Endpoint (EICE)** for secure access through the AWS Console. **No SSH keys required!** The EICE allows you to connect to private instances using their private IP addresses directly through the AWS Console.

### Using AWS Console (Recommended)

**No SSH keys required!** Simply use the AWS Console:

1. **Navigate to EC2 Console**:
   - Go to AWS Console → EC2 → Instances
   - Find your instances by name (e.g., `terraform-vpc-public-instance`)

2. **Connect to Public Instance**:
   - Select the public instance
   - Click "Connect" button
   - Choose "EC2 Instance Connect" tab
   - Click "Connect" for browser-based SSH session
   - **Can also be accessed via private IP through EICE**

3. **Connect to Private Instance (using EICE)**:
   - Select the private instance
   - Click "Connect" button
   - Choose "EC2 Instance Connect" tab
   - The connection will use the EICE to reach the private instance via its private IP
   - **No SSH keys needed!**


### Instance Information

Get instance details from Terraform outputs:
```bash
# Get all outputs
terraform output

# Get specific outputs
terraform output public_instance_public_ip
terraform output private_instance_private_ip
terraform output nat_instance_public_ip

# Get EICE information
terraform output ec2_instance_connect_endpoint_id
terraform output ec2_instance_connect_endpoint_dns_name
```

### EC2 Instance Connect Endpoint Benefits

- **Direct Private Access**: Connect to both public and private instances using their private IP addresses
- **Enhanced Security**: No need to expose instances through public internet
- **Simplified Architecture**: Eliminates the need for bastion hosts or jump servers
- **Cost Effective**: Reduces the need for additional NAT Gateway or public instances
- **Unified Access**: Both public and private instances accessible through the same EICE

## VPC Endpoints

This infrastructure includes VPC endpoints for secure, private connectivity to AWS services:

### **Gateway Endpoints** (No additional cost)
- **S3**: Private access to S3 buckets and objects
- **DynamoDB**: Private access to DynamoDB tables

### **Interface Endpoints** (Additional cost)
- **SQS**: Private access to SQS queues
- **RDS**: Private access to RDS instances

### **VPC Endpoint Benefits**
- **Enhanced Security**: Traffic stays within AWS network
- **Reduced Latency**: Direct connection to AWS services
- **Cost Optimization**: Reduced NAT Gateway data transfer costs
- **Compliance**: Meets requirements for private-only access

### **Accessing VPC Endpoints**
```bash
# Get VPC endpoint information
terraform output vpc_endpoints

# Check endpoint status
aws ec2 describe-vpc-endpoints --vpc-endpoint-ids $(terraform output -raw vpc_endpoints | jq -r '.s3_endpoint_id')
```

## Cost Optimization

- **NAT Gateway**: Consider using a NAT instance instead of NAT Gateway for cost savings
- **Instance Types**: Use smaller instance types for development/testing
- **AMI**: Use Amazon Linux 2 for better cost efficiency

## Cleanup

To destroy all resources:

```bash
terraform destroy -auto-approve

echo "Cleaning up state files..."
rm -f terraform.tfstate*
rm -rf .terraform/
rm -f .terraform.lock.hcl

```
**Warning**: This will delete all resources created by this Terraform configuration.

## Troubleshooting

### Common Issues

1. **EC2 Instance Connect Endpoint Connection Issues**:
   - **Error**: "Failed to connect to your instance"
   - **Solution**: Ensure the EICE is deployed in the same VPC and has proper security group rules
   - **Check**: Verify EICE status in AWS Console → VPC → Endpoints

2. **Private Instance Access Issues**:
   - **Error**: "Error establishing SSH connection to your instance"
   - **Solution**: Ensure private instance security group allows SSH from EICE
   - **Check**: Verify security group rules allow port 22 from EICE security group

3. **EICE Security Group Issues**:
   - **Error**: EICE cannot reach instances
   - **Solution**: Ensure EICE security group has outbound SSH (port 22) to VPC
   - **Check**: Verify EICE security group egress rules

4. **No SSH Keys Required**: This infrastructure uses EC2 Instance Connect without SSH keys
5. **AMI Not Found**: Update the AMI ID in variables for your region
6. **Insufficient Permissions**: Ensure your AWS credentials have necessary permissions

### Useful Commands

```bash
# Check Terraform state
terraform state list

# View specific resource
terraform state show aws_instance.public

# Refresh state
terraform refresh

# Validate configuration
terraform validate

# Check EICE status
terraform output ec2_instance_connect_endpoint_id

# Check security group rules
aws ec2 describe-security-groups --group-ids $(terraform output -raw security_group_ids | jq -r '.eice')

# Check EICE connectivity (no SSH keys needed)
aws ec2 describe-instance-connect-endpoints \
  --instance-connect-endpoint-ids $(terraform output -raw ec2_instance_connect_endpoint_id)
```

### EICE Troubleshooting Steps

1. **Verify EICE Status**:
   ```bash
   aws ec2 describe-instance-connect-endpoints --filters "Name=state,Values=available"
   ```

2. **Check Security Groups**:
   ```bash
   # Get EICE security group ID
   EICE_SG=$(terraform output -raw security_group_ids | jq -r '.eice')
   
   # Check egress rules
   aws ec2 describe-security-groups --group-ids $EICE_SG
   ```

3. **Test Private Instance Access**:
   ```bash
   # Get private instance ID
   PRIVATE_INSTANCE_ID=$(terraform output -raw private_instance_id)
   
   # Check if instance is running
   aws ec2 describe-instances --instance-ids $PRIVATE_INSTANCE_ID \
     --query 'Reservations[0].Instances[0].State.Name'
   ```

4. **Check EICE Status and Debugging**:
   ```bash
   # Get debugging information
   terraform output debugging_info
   
   # Check EICE state
   terraform output ec2_instance_connect_endpoint_state
   
   # Verify EICE is in correct subnet
   terraform output ec2_instance_connect_endpoint_subnet_id
   
   # Check if EICE is available
   aws ec2 describe-instance-connect-endpoints \
     --instance-connect-endpoint-ids $(terraform output -raw ec2_instance_connect_endpoint_id)
   ```

5. **Verify Network Connectivity**:
   ```bash
   # Check if private instances are reachable from EICE subnet
   PRIVATE_INSTANCE_IP=$(terraform output -raw private_instance_private_ip)
   EICE_SUBNET=$(terraform output -raw ec2_instance_connect_endpoint_subnet_id)
   
   echo "EICE Subnet: $EICE_SUBNET"
   echo "Private Instance IP: $PRIVATE_INSTANCE_IP"
   ```

## Security Considerations

1. **SSH Access**: Restrict SSH access to specific IP ranges in production
2. **Security Groups**: Review and tighten security group rules
3. **Key Management**: Use AWS Systems Manager Parameter Store for sensitive data
4. **Monitoring**: Enable CloudTrail and VPC Flow Logs for monitoring

## Next Steps

- Add Application Load Balancer for high availability
- Implement Auto Scaling Groups
- Add RDS database in private subnets
- Set up CloudWatch monitoring and alerts
- Implement backup strategies