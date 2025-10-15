# IAM Role for EC2 Instance Connect
resource "aws_iam_role" "ec2_connect_role" {
  name = "${var.project_name}-ec2-connect-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-connect-role"
  }
}

# IAM Policy for EC2 Instance Connect
resource "aws_iam_role_policy" "ec2_connect_policy" {
  name = "${var.project_name}-ec2-connect-policy"
  role = aws_iam_role.ec2_connect_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2-instance-connect:SendSSHPublicKey",
          "ec2-instance-connect:SendSerialConsoleSSHPublicKey"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceConnectEndpoints"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_connect_profile" {
  name = "${var.project_name}-ec2-connect-profile"
  role = aws_iam_role.ec2_connect_role.name

  tags = {
    Name = "${var.project_name}-ec2-connect-profile"
  }
}
