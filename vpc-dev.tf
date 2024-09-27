############ Region-1 VPC Development A ###############
resource "aws_vpc" "region1-vpc-dev-a" {
    provider            = aws.region1

    cidr_block           = var.region1-vpccidr-dev-a
    enable_dns_support   = true
    enable_dns_hostnames = true
    instance_tenancy     = "default"
    tags = {
        Name = "VPC Development A ${var.region1}"
    }
}

# // Public subnet Region-1 AZ-1
resource "aws_subnet" "region1-publicsubnetaz1-dev-a" {
    provider            = aws.region1

    vpc_id            = aws_vpc.region1-vpc-dev-a.id
    cidr_block        = cidrsubnet(var.region1-vpccidr-dev-a, 8, 0)
    availability_zone = var.region1-az1
    tags = {
        Name = "dev-a-public-subnet-${var.region1-az1}"
    }
}

resource "aws_subnet" "region1-privatesubnetaz1-dev-a" {
    provider            = aws.region1

    vpc_id            = aws_vpc.region1-vpc-dev-a.id
    cidr_block        = cidrsubnet(var.region1-vpccidr-dev-a, 8, 2)
    availability_zone = var.region1-az1
    tags = {
        Name = "dev-a-private-subnet-${var.region1-az1}"
    }
}

// Public Route Table
resource "aws_route_table" "region1-dev-a-public-rtb" {
    provider            = aws.region1

    vpc_id   = aws_vpc.region1-vpc-dev-a.id

    tags = {
        Name = "dev-a-public-rtb-${var.region1}"
    }
}

// Private Route Table
resource "aws_route_table" "region1-dev-a-private-rtb" {
    provider            = aws.region1

    vpc_id   = aws_vpc.region1-vpc-dev-a.id
    tags = {
        Name = "dev-a-private-rtb-${var.region1}"
    }
}

//public subnet route table association Region-1 
resource "aws_route_table_association" "region1-dev-a-public-associate" {
    provider            = aws.region1
    subnet_id      = aws_subnet.region1-publicsubnetaz1-dev-a.id
    route_table_id = aws_route_table.region1-dev-a-public-rtb.id
}

//private subnet route table association  Region-1
resource "aws_route_table_association" "region1-dev-a-private-associate" {
    provider            = aws.region1

    subnet_id      = aws_subnet.region1-privatesubnetaz1-dev-a.id
    route_table_id = aws_route_table.region1-dev-a-private-rtb.id
}


# ---------- EC2 INSTANCES Region-1 ----------
# Security Group
resource "aws_security_group" "region1-instance_sg_dev_a" {
    provider            = aws.region1

    name        = "region-1-sg_dev_a"
    description = "EC2 Instance Security Group"
    vpc_id      = aws_vpc.region1-vpc-dev-a.id
}

resource "aws_vpc_security_group_ingress_rule" "region1-dev-a-allowing_ingres_all" {
    provider            = aws.region1

    security_group_id = aws_security_group.region1-instance_sg_dev_a.id

    ip_protocol = "-1"
    cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "region1-dev-a-allowing_egress_any" {
    provider            = aws.region1

    security_group_id = aws_security_group.region1-instance_sg_dev_a.id
    ip_protocol = "-1"
    cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_instance" "region1-dev-a" {
    provider            = aws.region1

    ami                         = data.aws_ami.region1-amazon_linux.id
    associate_public_ip_address = false
    instance_type               = "t2.micro"
    vpc_security_group_ids      = [aws_security_group.region1-instance_sg_dev_a.id]
    subnet_id                   = aws_subnet.region1-publicsubnetaz1-dev-a.id
    key_name                    = var.region1-keyname


    metadata_options {
        http_endpoint = "enabled"
        http_tokens   = "required"
    }

    root_block_device {
        encrypted = true
    }

    tags = {
        Name = "Instance-Dev-A-${var.region1}"
    }
    user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install -y httpd
        systemctl start httpd.service
        systemctl enable httpd.service
        echo "<font face = "Verdana" size = "5">" > /var/www/html/index.html
        echo "<center><h1>Instance dev-A ${var.region1} </h1></center>" >> /var/www/html/index.html
        EOF

}

############ Region-2 VPC Development B ###############
resource "aws_vpc" "region2-vpc-dev-b" {
    provider            = aws.region2

    cidr_block           = var.region2-vpccidr-dev-b
    enable_dns_support   = true
    enable_dns_hostnames = true
    instance_tenancy     = "default"
    tags = {
        Name = "VPC Development B ${var.region2}"
    }
}

# // Public subnet Region-1 AZ-1
resource "aws_subnet" "region2-publicsubnetaz1-dev-b" {
    provider            = aws.region2

    vpc_id            = aws_vpc.region2-vpc-dev-b.id
    cidr_block        = cidrsubnet(var.region2-vpccidr-dev-b, 8, 0)
    availability_zone = var.region2-az1
    tags = {
        Name = "dev-b-public-subnet-${var.region2-az1}"
    }
}

resource "aws_subnet" "region2-privatesubnetaz1-dev-b" {
    provider            = aws.region2

    vpc_id            = aws_vpc.region2-vpc-dev-b.id
    cidr_block        = cidrsubnet(var.region2-vpccidr-dev-b, 8, 2)
    availability_zone = var.region2-az1
    tags = {
        Name = "dev-b-private-subnet-${var.region2-az1}"
    }
}

// Public Route Table
resource "aws_route_table" "region2-dev-b-public-rtb" {
    provider            = aws.region2

    vpc_id   = aws_vpc.region2-vpc-dev-b.id

    tags = {
        Name = "dev-b-public-rtb-${var.region2}"
    }
}

// Private Route Table
resource "aws_route_table" "region2-dev-b-private-rtb" {
    provider            = aws.region2

    vpc_id   = aws_vpc.region2-vpc-dev-b.id
    tags = {
        Name = "dev-b-private-rtb-${var.region2}"
    }
}

//public subnet route table association Region-2
resource "aws_route_table_association" "region2-dev-b-public-associate" {
    provider            = aws.region2
    subnet_id           = aws_subnet.region2-publicsubnetaz1-dev-b.id
    route_table_id      = aws_route_table.region2-dev-b-public-rtb.id
}

//private subnet route table association  Region-2
resource "aws_route_table_association" "region2-dev-b-private-associate" {
    provider            = aws.region2

    subnet_id      = aws_subnet.region2-privatesubnetaz1-dev-b.id
    route_table_id = aws_route_table.region2-dev-b-private-rtb.id
}


# ---------- EC2 INSTANCES Region-2 ----------
# Security Group
resource "aws_security_group" "region2-instance_sg_dev_b" {
    provider            = aws.region2

    name        = "region-2-sg_dev_b"
    description = "EC2 Instance Security Group"
    vpc_id      = aws_vpc.region2-vpc-dev-b.id
}

resource "aws_vpc_security_group_ingress_rule" "region2-dev-b-allowing_ingres_all" {
    provider            = aws.region2

    security_group_id = aws_security_group.region2-instance_sg_dev_b.id

    ip_protocol = "-1"
    cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "region2-dev-b-allowing_egress_any" {
    provider            = aws.region2

    security_group_id = aws_security_group.region2-instance_sg_dev_b.id
    ip_protocol = "-1"
    cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_instance" "region2-dev-b" {
    provider            = aws.region2

    ami                         = data.aws_ami.region2-amazon_linux.id
    associate_public_ip_address = false
    instance_type               = "t2.micro"
    vpc_security_group_ids      = [aws_security_group.region2-instance_sg_dev_b.id]
    subnet_id                   = aws_subnet.region2-publicsubnetaz1-dev-b.id
    key_name                    = var.region2-keyname


    metadata_options {
        http_endpoint = "enabled"
        http_tokens   = "required"
    }

    root_block_device {
        encrypted = true
    }

    tags = {
        Name = "Instance-Dev-B-${var.region2}"
    }
    user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install -y httpd
        systemctl start httpd.service
        systemctl enable httpd.service
        echo "<font face = "Verdana" size = "5">" > /var/www/html/index.html
        echo "<center><h1>Instance Dev-B ${var.region2}</h1></center>" >> /var/www/html/index.html
        EOF

}

