data "aws_ami" "region1-amazon_linux" {
  provider    = aws.region1
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
data "aws_ami" "region2-amazon_linux" {
  provider    = aws.region2
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

####### Fetching GWLB IPS in Region-1

data "aws_network_interface" "region1-gwlbe-az1" {
  provider = aws.region1
  depends_on = [aws_lb.region1-gateway_lb]
  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.region1-sec-vpc.id}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "description"
    values = ["*ELB*"]
  }
  filter {
    name   = "availability-zone"
    values = ["${var.region1-az1}"]
  }
}

data "aws_network_interface" "region1-gwlbe-az2" {
  provider = aws.region1
  depends_on = [aws_lb.region1-gateway_lb]
  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.region1-sec-vpc.id}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "description"
    values = ["*ELB*"]
  }
  filter {
    name   = "availability-zone"
    values = ["${var.region1-az2}"]
  }
}



####### Fetching GWLB IPS in Region-2
data "aws_network_interface" "region2-gwlbe-az1" {
  provider = aws.region2
  depends_on = [aws_lb.region2-gateway_lb]
  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.region2-sec-vpc.id}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "description"
    values = ["*ELB*"]
  }
  filter {
    name   = "availability-zone"
    values = ["${var.region2-az1}"]
  }
}

data "aws_network_interface" "region2-gwlbe-az2" {
  provider = aws.region2
  depends_on = [aws_lb.region2-gateway_lb]
  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.region2-sec-vpc.id}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "description"
    values = ["*ELB*"]
  }
  filter {
    name   = "availability-zone"
    values = ["${var.region2-az2}"]
  }
}