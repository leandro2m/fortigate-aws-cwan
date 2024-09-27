############ Region-1 VPC Production A ###############
resource "aws_vpc" "region1-vpc-prod-a" {
    provider            = aws.region1

    cidr_block           = var.region1-vpccidr-prod-a
    enable_dns_support   = true
    enable_dns_hostnames = true
    instance_tenancy     = "default"
    tags = {
        Name = "VPC Production A ${var.region1}"
    }
}

# // Public subnet Region-1 AZ-1
resource "aws_subnet" "region1-publicsubnetaz1-prod-a" {
    provider            = aws.region1

    vpc_id            = aws_vpc.region1-vpc-prod-a.id
    cidr_block        = cidrsubnet(var.region1-vpccidr-prod-a, 8, 0)
    availability_zone = var.region1-az1
    tags = {
        Name = "prod-a-public-subnet-${var.region1-az1}"
    }
}

resource "aws_subnet" "region1-privatesubnetaz1-prod-a" {
    provider            = aws.region1

    vpc_id            = aws_vpc.region1-vpc-prod-a.id
    cidr_block        = cidrsubnet(var.region1-vpccidr-prod-a, 8, 2)
    availability_zone = var.region1-az1
    tags = {
        Name = "prod-a-private-subnet-${var.region1-az1}"
    }
}

// Public Route Table
resource "aws_route_table" "region1-prod-a-public-rtb" {
    provider            = aws.region1

    vpc_id   = aws_vpc.region1-vpc-prod-a.id

    tags = {
        Name = "prod-a-public-rtb-${var.region1}"
    }
}

// Private Route Table
resource "aws_route_table" "region1-prod-a-private-rtb" {
    provider            = aws.region1

    vpc_id   = aws_vpc.region1-vpc-prod-a.id
    tags = {
        Name = "prod-a-private-rtb-${var.region1}"
    }
}

//public subnet route table association Region-1 
resource "aws_route_table_association" "region1-public-associate" {
    provider            = aws.region1
    subnet_id      = aws_subnet.region1-publicsubnetaz1-prod-a.id
    route_table_id = aws_route_table.region1-prod-a-public-rtb.id
}

//private subnet route table association  Region-1
resource "aws_route_table_association" "region1-private-associate" {
    provider            = aws.region1

    subnet_id      = aws_subnet.region1-privatesubnetaz1-prod-a.id
    route_table_id = aws_route_table.region1-prod-a-private-rtb.id
}

// Creating Internet Gateway Prod-A Region-1 
resource "aws_internet_gateway" "region1-prod-a-igw" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-vpc-prod-a.id
    tags = {
        Name = "prod-a-igw-${var.region1}"
    }
}

//default route Public RTB to IGW 
resource "aws_route" "region1-prod-a-default" {
    depends_on             = [aws_internet_gateway.region1-prod-a-igw]
    provider               = aws.region1
    route_table_id         = aws_route_table.region1-prod-a-public-rtb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.region1-prod-a-igw.id
}

# ---------- EC2 INSTANCES Region-1 ----------
# Security Group
resource "aws_security_group" "region1-instance_sg_prod_a" {
    provider            = aws.region1

    name        = "region-1-sg_prod_a"
    description = "EC2 Instance Security Group"
    vpc_id      = aws_vpc.region1-vpc-prod-a.id
}

resource "aws_vpc_security_group_ingress_rule" "region1-allowing_ingres_all" {
    provider            = aws.region1

    security_group_id = aws_security_group.region1-instance_sg_prod_a.id

    ip_protocol = "-1"
    cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "region1-allowing_egress_any" {
    provider            = aws.region1

    security_group_id = aws_security_group.region1-instance_sg_prod_a.id
    ip_protocol = "-1"
    cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_instance" "region1-prod-a" {
    provider            = aws.region1

    ami                         = data.aws_ami.region1-amazon_linux.id
    associate_public_ip_address = true
    instance_type               = "t2.micro"
    vpc_security_group_ids      = [aws_security_group.region1-instance_sg_prod_a.id]
    subnet_id                   = aws_subnet.region1-publicsubnetaz1-prod-a.id
    key_name                    = var.region1-keyname


    metadata_options {
        http_endpoint = "enabled"
        http_tokens   = "required"
    }

    root_block_device {
        encrypted = true
    }

    tags = {
        Name = "Instance-Prod-A-${var.region1-az1}"
    }
    user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install -y httpd
        systemctl start httpd.service
        systemctl enable httpd.service
        echo "<font face = "Verdana" size = "5">" > /var/www/html/index.html
        echo "<center><h1>Instance Prod-A ${var.region1-az1} </h1></center>" >> /var/www/html/index.html
        EOF

}

############ Region-2 VPC Production A ###############
resource "aws_vpc" "region2-vpc-prod-b" {
    provider            = aws.region2

    cidr_block           = var.region2-vpccidr-prod-b
    enable_dns_support   = true
    enable_dns_hostnames = true
    instance_tenancy     = "default"
    tags = {
        Name = "VPC Production B ${var.region2}"
    }
}

# // Public subnet Region-1 AZ-1
resource "aws_subnet" "region2-publicsubnetaz1-prod-b" {
    provider            = aws.region2

    vpc_id              = aws_vpc.region2-vpc-prod-b.id
    cidr_block          = cidrsubnet(var.region2-vpccidr-prod-b, 8, 0)
    availability_zone   = var.region2-az1
    tags = {
        Name = "prod-b-public-subnet-${var.region2-az1}"
    }
}

resource "aws_subnet" "region2-privatesubnetaz1-prod-b" {
    provider            = aws.region2

    vpc_id              = aws_vpc.region2-vpc-prod-b.id
    cidr_block          = cidrsubnet(var.region2-vpccidr-prod-b, 8, 2)
    availability_zone   = var.region2-az1
    tags = {
        Name = "prod-b-private-subnet-${var.region2-az1}"
    }
}

// Public Route Table
resource "aws_route_table" "region2-prod-b-public-rtb" {
    provider            = aws.region2

    vpc_id              = aws_vpc.region2-vpc-prod-b.id

    tags = {
        Name = "prod-b-public-rtb-${var.region2}"
    }
}

// Private Route Table
resource "aws_route_table" "region2-prod-b-private-rtb" {
    provider            = aws.region2

    vpc_id              = aws_vpc.region2-vpc-prod-b.id
    tags = {
        Name = "prod-b-private-rtb-${var.region2}"
    }
}

//public subnet route table association Region-2
resource "aws_route_table_association" "region2-prod-b-public-associate" {
    provider            = aws.region2
    subnet_id           = aws_subnet.region2-publicsubnetaz1-prod-b.id
    route_table_id      = aws_route_table.region2-prod-b-public-rtb.id
}

//private subnet route table association  Region-2
resource "aws_route_table_association" "region2-prod-b-private-associate" {
    provider            = aws.region2

    subnet_id      = aws_subnet.region2-privatesubnetaz1-prod-b.id
    route_table_id = aws_route_table.region2-prod-b-private-rtb.id
}

// Creating Internet Gateway Prod-B Region-2 
resource "aws_internet_gateway" "region2-prod-b-igw" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-vpc-prod-b.id
    tags = {
        Name = "prod-b-igw-${var.region2}"
    }
}

//default route Public RTB to IGW Region 2
resource "aws_route" "region2-prod-b-default" {
    depends_on             = [aws_internet_gateway.region2-prod-b-igw]
    provider               = aws.region2
    route_table_id         = aws_route_table.region2-prod-b-public-rtb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.region2-prod-b-igw.id
}


# ---------- EC2 INSTANCES Region-2 ----------
# Security Group
resource "aws_security_group" "region2-instance_sg_prod_b" {
    provider            = aws.region2

    name        = "region-2-sg_prod_b"
    description = "EC2 Instance Security Group"
    vpc_id      = aws_vpc.region2-vpc-prod-b.id
}

resource "aws_vpc_security_group_ingress_rule" "region2-prod-b-allowing_ingres_all" {
    provider            = aws.region2

    security_group_id = aws_security_group.region2-instance_sg_prod_b.id

    ip_protocol = "-1"
    cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "region2-prod-b-allowing_egress_any" {
    provider            = aws.region2

    security_group_id = aws_security_group.region2-instance_sg_prod_b.id
    ip_protocol = "-1"
    cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_instance" "region2-prod-b" {
    provider            = aws.region2

    ami                         = data.aws_ami.region2-amazon_linux.id
    associate_public_ip_address = true
    instance_type               = "t2.micro"
    vpc_security_group_ids      = [aws_security_group.region2-instance_sg_prod_b.id]
    subnet_id                   = aws_subnet.region2-publicsubnetaz1-prod-b.id
    key_name                    = var.region2-keyname


    metadata_options {
        http_endpoint = "enabled"
        http_tokens   = "required"
    }

    root_block_device {
        encrypted = true
    }

    tags = {
        Name = "Instance-Prod-B-${var.region2-az1}"
    }
    user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install -y httpd
        systemctl start httpd.service
        systemctl enable httpd.service
        echo "<font face = "Verdana" size = "5">" > /var/www/html/index.html
        echo "<center><h1>Instance Prod-B ${var.region2-az1}</h1></center>" >> /var/www/html/index.html
        EOF

}

