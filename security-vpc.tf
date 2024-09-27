// AWS Security VPC Region 1
resource "aws_vpc" "region1-sec-vpc" {
  provider             = aws.region1
  cidr_block           = var.region1-vpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "Security VPC ${var.region1}"
  }
}
# // public subnet Region-1 AZ-1
resource "aws_subnet" "region1-publicsubnetaz1" {
    provider             = aws.region1
    vpc_id               = aws_vpc.region1-sec-vpc.id
    cidr_block           = cidrsubnet(var.region1-vpccidr, 8, 0)
    availability_zone    = var.region1-az1
    tags = {
        Name = "public-subnet-${var.region1-az1}"
    }
}
#public subnet Region-1 AZ2
resource "aws_subnet" "region1-publicsubnetaz2" {
    provider             = aws.region1
    vpc_id               = aws_vpc.region1-sec-vpc.id
    cidr_block           = cidrsubnet(var.region1-vpccidr, 8, 10)
    availability_zone    = var.region1-az2
    tags = {
        Name = "public-subnet-${var.region1-az2}"
    }
}

resource "aws_subnet" "region1-privatesubnetaz1" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-sec-vpc.id
    cidr_block        = cidrsubnet(var.region1-vpccidr, 8, 1)
    availability_zone = var.region1-az1
    tags = {
        Name = "private-subnet-${var.region1-az1}"
    }
}
resource "aws_subnet" "region1-privatesubnetaz2" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-sec-vpc.id
    cidr_block        = cidrsubnet(var.region1-vpccidr, 8, 11)
    availability_zone = var.region1-az2
    tags = {
        Name = "private-subnet-${var.region1-az2}"
    }
}

resource "aws_subnet" "region1-cwansubnetaz1" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-sec-vpc.id
    cidr_block        = cidrsubnet(var.region1-vpccidr, 8, 2)
    availability_zone = var.region1-az1
    tags = {
        Name = "cwan-subnet-${var.region1-az1}"
    }
}

resource "aws_subnet" "region1-cwansubnetaz2" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-sec-vpc.id
    cidr_block        = cidrsubnet(var.region1-vpccidr, 8, 12)
    availability_zone = var.region1-az2
    tags = {
        Name = "cwan-subnet-${var.region1-az2}"
    }
}

resource "aws_subnet" "region1-gwlbeaz1" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-sec-vpc.id
    cidr_block        = cidrsubnet(var.region1-vpccidr, 8, 3)
    availability_zone = var.region1-az1
    tags = {
        Name = "gwlbe-subnet-${var.region1-az1}"
    }
}
resource "aws_subnet" "region1-gwlbeaz2" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-sec-vpc.id
    cidr_block        = cidrsubnet(var.region1-vpccidr, 8, 13)
    availability_zone = var.region1-az2
    tags = {
        Name = "gwlbe-subnet-${var.region1-az2}"
    }
}
// Creating Internet Gateway Region-1
resource "aws_internet_gateway" "region1-igw" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-sec-vpc.id
    tags = {
        Name = "security-vpc-igw-${var.region1}"
    }
}

// Public Route Table
resource "aws_route_table" "region1-secvpcpublicrtb" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-sec-vpc.id
    tags = {
        Name = "sec-vpc-public-rtb-${var.region1}"
    }
}
// Private Route Table Sec-VPC Region1
resource "aws_route_table" "region1-secvpcprivatertb" {
    provider          = aws.region1
    vpc_id   = aws_vpc.region1-sec-vpc.id
    tags = {
        Name = "sec-vpc-private-rtb-${var.region1}"
    }
}
// Private Route Table Sec-VPC Region-1
resource "aws_route_table" "region1-secvpccwanrtb" {
    provider          = aws.region1
    vpc_id   = aws_vpc.region1-sec-vpc.id
    tags = {
        Name = "sec-vpc-cwan-rtb-${var.region1}"
    }
}
// GWLBE Route Table GWLBE Sec-VPC Region-1
resource "aws_route_table" "region1-secvpcgwlbertb" {
    provider          = aws.region1
    vpc_id            = aws_vpc.region1-sec-vpc.id
    tags = {
        Name = "sec-vpc-gwlbe-rtb-${var.region1}"
    }
}

//default route Public RTB to IGW 
resource "aws_route" "region1-externalroute" {
    provider                = aws.region1
    route_table_id         = aws_route_table.region1-secvpcpublicrtb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.region1-igw.id
}
// Default route in CWAN RTB to FortiGate-IP Region-1
resource "aws_route" "region1-cwanroute" {
    provider                = aws.region1
    depends_on              = [aws_vpc_endpoint.region1-gwlbendpointsecvpcaz1]
    route_table_id          = aws_route_table.region1-secvpccwanrtb.id
    destination_cidr_block  = "0.0.0.0/0"
#   network_interface_id    = aws_network_interface.region1-eth1.id
    vpc_endpoint_id         = aws_vpc_endpoint.region1-gwlbendpointsecvpcaz1.id
}

# Default Route to GWLBE in RTB Subnet-CWAN
# resource "aws_route" "region1-cwanroutetabledefaultroute" {
#   depends_on             = [aws_instance.fgtactive]
#   route_table_id         = aws_route_table.secvpccwanrtb.id
#   destination_cidr_block = "0.0.0.0/0"
#   network_interface_id   = aws_network_interface.eth1.id
# }

# //  MSR route to Public IP of FortiGate-IP Active
# # resource "aws_route" "region1-cwanroutetabledefaultroute-public" {
# #   depends_on             = [aws_instance.fgtactive]
# #   route_table_id         = aws_route_table.secvpccwanrtb.id
# #   destination_cidr_block = cidrsubnet(var.vpccidr, 8, 0)
# #   network_interface_id   = aws_network_interface.eth1.id
# # }
# //  MSR route to Public IP of FortiGate-IP Active
# # resource "aws_route" "region1-cwanroutetabledefaultroute-public1" {
# #   depends_on             = [aws_instance.fgtactive]
# #   route_table_id         = aws_route_table.secvpccwanrtb.id
# #   destination_cidr_block = cidrsubnet(var.vpccidr, 8, 1)
# #   network_interface_id   = aws_network_interface.eth1.id
# # }
# //  MSR route to Public IP of FortiGate-IP
# # resource "aws_route" "region1-fortigate-public-route" {
# #   depends_on             = [aws_instance.fgtactive]
# #   route_table_id         = aws_route_table.secvpcprivatertb.id
# #   destination_cidr_block = cidrsubnet(var.vpccidr, 8, 0)
# #   network_interface_id   = aws_network_interface.eth1.id
# # }

# # //  route to Public IP of FortiGate Passive
# # resource "aws_route" "fortigate-passive-public-route" {
# #   depends_on             = [aws_instance.ftgtpassive]
# #   route_table_id         = aws_route_table.secvpcprivatertb.id
# #   destination_cidr_block = cidrsubnet(var.vpccidr, 8, 1)
# #   network_interface_id   = aws_network_interface.passive-eth1.id
# # }

//public route table subnet association Region-1 AZ1
resource "aws_route_table_association" "region1-public1associate" {
    provider       = aws.region1
    subnet_id      = aws_subnet.region1-publicsubnetaz1.id
    route_table_id = aws_route_table.region1-secvpcpublicrtb.id
}

# //public route table subnet association Region-1 AZ2
resource "aws_route_table_association" "region1-public2associate" {
    provider        = aws.region1
    subnet_id       = aws_subnet.region1-publicsubnetaz2.id
    route_table_id  = aws_route_table.region1-secvpcpublicrtb.id
}


//private route table subnet association Region-1 az1
resource "aws_route_table_association" "region1-internalassociate" {
  provider          = aws.region1
  subnet_id         = aws_subnet.region1-privatesubnetaz1.id
  route_table_id    = aws_route_table.region1-secvpcprivatertb.id
}

//private route table subnet association Region-1 az2
resource "aws_route_table_association" "region1-internal2associate" {
  provider          = aws.region1
  subnet_id         = aws_subnet.region1-privatesubnetaz2.id
  route_table_id    = aws_route_table.region1-secvpcprivatertb.id
}

//cwan route table subnet association Region-1 az1
resource "aws_route_table_association" "region1-cwan1associate" {
    provider        = aws.region1
    subnet_id       = aws_subnet.region1-cwansubnetaz1.id
    route_table_id  = aws_route_table.region1-secvpccwanrtb.id
}
//cwan route table subnet association Regon-1 az2
resource "aws_route_table_association" "region1-cwan2associate" {
    provider       = aws.region1
    subnet_id      = aws_subnet.region1-cwansubnetaz2.id
    route_table_id = aws_route_table.region1-secvpccwanrtb.id
}

//gwlbe route table association az1
resource "aws_route_table_association" "region1-gwlbe1associate" {
    provider       = aws.region1
    subnet_id      = aws_subnet.region1-gwlbeaz1.id
    route_table_id = aws_route_table.region1-secvpcgwlbertb.id
}

resource "aws_security_group" "region1-allow_all" {
    provider       = aws.region1
    name        = "Allow All Sec-VPC"
    description = "Allow all traffic"
    vpc_id      = aws_vpc.region1-sec-vpc.id

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Allow Allow"
    }
}


#############################################################
####### Region 2 ############

// AWS Security VPC Region 2
resource "aws_vpc" "region2-sec-vpc" {
  provider             = aws.region2
  cidr_block           = var.region2-vpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "Security VPC ${var.region2}"
  }
}


# // public subnet Region-2 AZ-1
resource "aws_subnet" "region2-publicsubnetaz1" {
    provider             = aws.region2
    vpc_id               = aws_vpc.region2-sec-vpc.id
    cidr_block           = cidrsubnet(var.region2-vpccidr, 8, 0)
    availability_zone    = var.region2-az1
    tags = {
        Name = "public-subnet-${var.region2-az1}"
    }
}
#public subnet Region-2 AZ2
resource "aws_subnet" "region2-publicsubnetaz2" {
    provider             = aws.region2
    vpc_id               = aws_vpc.region2-sec-vpc.id
    cidr_block           = cidrsubnet(var.region2-vpccidr, 8, 10)
    availability_zone    = var.region2-az2
    tags = {
        Name = "public-subnet-${var.region2-az2}"
    }
}

resource "aws_subnet" "region2-privatesubnetaz1" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-sec-vpc.id
    cidr_block        = cidrsubnet(var.region2-vpccidr, 8, 1)
    availability_zone = var.region2-az1
    tags = {
        Name = "private-subnet-${var.region2-az1}"
    }
}
resource "aws_subnet" "region2-privatesubnetaz2" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-sec-vpc.id
    cidr_block        = cidrsubnet(var.region2-vpccidr, 8, 11)
    availability_zone = var.region2-az2
    tags = {
        Name = "private-subnet-${var.region2-az2}"
    }
}

resource "aws_subnet" "region2-cwansubnetaz1" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-sec-vpc.id
    cidr_block        = cidrsubnet(var.region2-vpccidr, 8, 2)
    availability_zone = var.region2-az1
    tags = {
        Name = "cwan-subnet-${var.region2-az1}"
    }
}

resource "aws_subnet" "region2-cwansubnetaz2" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-sec-vpc.id
    cidr_block        = cidrsubnet(var.region2-vpccidr, 8, 12)
    availability_zone = var.region2-az2
    tags = {
        Name = "cwan-subnet-${var.region2-az2}"
    }
}

resource "aws_subnet" "region2-gwlbeaz1" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-sec-vpc.id
    cidr_block        = cidrsubnet(var.region2-vpccidr, 8, 3)
    availability_zone = var.region2-az1
    tags = {
        Name = "gwlbe-subnet-${var.region2-az1}"
    }
}
resource "aws_subnet" "region2-gwlbeaz2" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-sec-vpc.id
    cidr_block        = cidrsubnet(var.region2-vpccidr, 8, 13)
    availability_zone = var.region2-az2
    tags = {
        Name = "gwlbe-subnet-${var.region2-az2}"
    }
}
// Creating Internet Gateway Region-2
resource "aws_internet_gateway" "region2-igw" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-sec-vpc.id
    tags = {
        Name = "security-vpc-igw-${var.region2}"
    }
}

// Public Route Table
resource "aws_route_table" "region2-secvpcpublicrtb" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-sec-vpc.id
    tags = {
        Name = "sec-vpc-public-rtb-${var.region2}"
    }
}
// Private Route Table Sec-VPC Region2
resource "aws_route_table" "region2-secvpcprivatertb" {
    provider         = aws.region2
    vpc_id           = aws_vpc.region2-sec-vpc.id
    tags = {
        Name = "sec-vpc-private-rtb-${var.region2}"
    }
}
// Private Route Table Sec-VPC Region-2
resource "aws_route_table" "region2-secvpccwanrtb" {
    provider        = aws.region2
    vpc_id          = aws_vpc.region2-sec-vpc.id
    tags = {
        Name = "sec-vpc-cwan-rtb-${var.region2}"
    }
}
// GWLBE Route Table GWLBE Sec-VPC Region-2
resource "aws_route_table" "region2-secvpcgwlbertb" {
    provider          = aws.region2
    vpc_id            = aws_vpc.region2-sec-vpc.id
    tags = {
        Name = "sec-vpc-gwlbe-rtb-${var.region2}"
    }
}

//default route Public RTB to IGW 
resource "aws_route" "region2-externalroute" {
    provider               = aws.region2
    route_table_id         = aws_route_table.region2-secvpcpublicrtb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.region2-igw.id
}

//public route table subnet association Region-2 AZ1
resource "aws_route_table_association" "region2-public1associate" {
    provider       = aws.region2
    subnet_id      = aws_subnet.region2-publicsubnetaz1.id
    route_table_id = aws_route_table.region2-secvpcpublicrtb.id
}

# //public route table subnet association Region-2 AZ2
resource "aws_route_table_association" "region2-public2associate" {
    provider        = aws.region2
    subnet_id       = aws_subnet.region2-publicsubnetaz2.id
    route_table_id  = aws_route_table.region2-secvpcpublicrtb.id
}


//private route table subnet association Region-2 az1
resource "aws_route_table_association" "region2-internalassociate" {
  provider          = aws.region2
  subnet_id         = aws_subnet.region2-privatesubnetaz1.id
  route_table_id    = aws_route_table.region2-secvpcprivatertb.id
}

//private route table subnet association Region-2 az2
resource "aws_route_table_association" "region2-internal2associate" {
  provider          = aws.region2
  subnet_id         = aws_subnet.region2-privatesubnetaz2.id
  route_table_id    = aws_route_table.region2-secvpcprivatertb.id
}

//cwan route table subnet association Region-2 az1
resource "aws_route_table_association" "region2-cwan1associate" {
    provider        = aws.region2
    subnet_id       = aws_subnet.region2-cwansubnetaz1.id
    route_table_id  = aws_route_table.region2-secvpccwanrtb.id
}
//cwan route table subnet association Regon-2 az2
resource "aws_route_table_association" "region2-cwan2associate" {
    provider       = aws.region2
    subnet_id      = aws_subnet.region2-cwansubnetaz2.id
    route_table_id = aws_route_table.region2-secvpccwanrtb.id
}

//gwlbe route table association az1
resource "aws_route_table_association" "region2-gwlbe1associate" {
    provider       = aws.region2
    subnet_id      = aws_subnet.region2-gwlbeaz1.id
    route_table_id = aws_route_table.region2-secvpcgwlbertb.id
}

resource "aws_security_group" "region2-allow_all" {
    provider       = aws.region2
    name        = "Allow All Sec-VPC"
    description = "Allow all traffic"
    vpc_id      = aws_vpc.region2-sec-vpc.id

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Allow Allow"
    }
}

// Default route in CWAN RTB to FortiGate-IP Region-2
resource "aws_route" "region2-cwanroute" {
    provider                = aws.region2
    depends_on              = [aws_vpc_endpoint.region2-gwlbendpointsecvpcaz1]
    route_table_id          = aws_route_table.region2-secvpccwanrtb.id
    destination_cidr_block  = "0.0.0.0/0"
#   network_interface_id    = aws_network_interface.region2-eth1.id
    vpc_endpoint_id         = aws_vpc_endpoint.region2-gwlbendpointsecvpcaz1.id
}