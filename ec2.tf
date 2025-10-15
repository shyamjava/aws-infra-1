# User Data for NAT Instance
locals {
  nat_user_data = <<-EOF
    #!/bin/bash
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
    service iptables save
  EOF
}

# NAT Instance
resource "aws_instance" "nat" {
  ami                    = var.nat_ami_id
  instance_type          = var.nat_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_connect_profile.name
  subnet_id             = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.nat_security_group_id]
  source_dest_check     = false
  user_data_base64      = base64encode(local.nat_user_data)

  tags = {
    Name = "${var.project_name}-nat-instance"
  }
}

# Public EC2 Instance
resource "aws_instance" "public" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_connect_profile.name
  subnet_id             = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.public_security_group_id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Public EC2 Instance</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-public-instance"
  }
}

# Private EC2 Instance
resource "aws_instance" "private" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_connect_profile.name
  subnet_id             = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.private_security_group_id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Private EC2 Instance</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-private-instance"
  }
}
