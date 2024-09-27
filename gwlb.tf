################# REGION-1 ################

//  Gateway Load Balancer in security VPC Region-1
resource "aws_lb" "region1-gateway_lb" {
    provider            = aws.region1
    name                             = "${var.region1}-GWLB"
    load_balancer_type               = "gateway"
    enable_cross_zone_load_balancing = true

    // AZ1
    subnet_mapping {
        subnet_id = aws_subnet.region1-privatesubnetaz1.id
    }

    // AZ2
    subnet_mapping {
        subnet_id = aws_subnet.region1-privatesubnetaz2.id
    }
}


//target Group 

resource "aws_lb_target_group" "region1-fgttarget" {
    provider            = aws.region1
    name        = "${var.region1}-fgttarget"
    port        = 6081
    protocol    = "GENEVE"
    target_type = "ip"
    vpc_id      = aws_vpc.region1-sec-vpc.id

    health_check {
        port     = 8008
        protocol = "TCP"
    }
}

resource "aws_lb_listener" "region1-fgtlistener" {
    provider            = aws.region1
    load_balancer_arn = aws_lb.region1-gateway_lb.id

    default_action {
        target_group_arn = aws_lb_target_group.region1-fgttarget.id
        type             = "forward"
    }
}

resource "aws_lb_target_group_attachment" "region1-fgtattach" {
    provider            = aws.region1
    depends_on       = [aws_instance.region1-fgtactive]
    target_group_arn = aws_lb_target_group.region1-fgttarget.arn
    target_id        = aws_network_interface.region1-eth1.private_ip
    port             = 6081
}

// GWLB Service Region 1
resource "aws_vpc_endpoint_service" "region1-fgtgwlbservice" {
    provider            = aws.region1

    acceptance_required        = false
    gateway_load_balancer_arns = [aws_lb.region1-gateway_lb.arn]
    tags = {
        Name = "GWLB-SERVICE-${var.region1}"
    }
}

//GWLBE For Security VPC in Region 1 AZ1 
resource "aws_vpc_endpoint" "region1-gwlbendpointsecvpcaz1" {
    provider            = aws.region1

    service_name      = aws_vpc_endpoint_service.region1-fgtgwlbservice.service_name
    subnet_ids        = [aws_subnet.region1-gwlbeaz1.id]
    vpc_endpoint_type = aws_vpc_endpoint_service.region1-fgtgwlbservice.service_type
    vpc_id            = aws_vpc.region1-sec-vpc.id
    tags = {
        Name = "FortiGate-VM-GWLBE-SECVPC-${var.region1-az1}"
    }
}
//GWLBE For Security VPC in AZ2

resource "aws_vpc_endpoint" "region1-gwlbendpointsecvpcaz2" {
    provider            = aws.region1

    service_name      = aws_vpc_endpoint_service.region1-fgtgwlbservice.service_name
    subnet_ids        = [aws_subnet.region1-gwlbeaz2.id]
    vpc_endpoint_type = aws_vpc_endpoint_service.region1-fgtgwlbservice.service_type
    vpc_id            = aws_vpc.region1-sec-vpc.id
    tags = {
        Name = "FortiGate-VM-GWLBE-SECVPC-${var.region1-az2}"
    }
}

################# REGION-2 ################


//  Gateway Load Balancer in security VPC Region-2
resource "aws_lb" "region2-gateway_lb" {
    provider                         = aws.region2
    name                             = "${var.region2}-GWLB"
    load_balancer_type               = "gateway"
    enable_cross_zone_load_balancing = true

    // AZ1
    subnet_mapping {
        subnet_id = aws_subnet.region2-privatesubnetaz1.id
    }

    // AZ2
    subnet_mapping {
        subnet_id = aws_subnet.region2-privatesubnetaz2.id
    }
}


//target Group 

resource "aws_lb_target_group" "region2-fgttarget" {
    provider            = aws.region2
    name        = "${var.region2}-fgttarget"
    port        = 6081
    protocol    = "GENEVE"
    target_type = "ip"
    vpc_id      = aws_vpc.region2-sec-vpc.id

    health_check {
        port     = 8008
        protocol = "TCP"
    }
}

resource "aws_lb_listener" "region2-fgtlistener" {
    provider            = aws.region2
    load_balancer_arn = aws_lb.region2-gateway_lb.id

    default_action {
        target_group_arn = aws_lb_target_group.region2-fgttarget.id
        type             = "forward"
    }
}

resource "aws_lb_target_group_attachment" "region2-fgtattach" {
    provider            = aws.region2
    depends_on          = [aws_instance.region2-fgtactive]
    target_group_arn    = aws_lb_target_group.region2-fgttarget.arn
    target_id           = aws_network_interface.region2-eth1.private_ip
    port                = 6081
}

// GWLB Service Region 2
resource "aws_vpc_endpoint_service" "region2-fgtgwlbservice" {
    provider                   = aws.region2

    acceptance_required        = false
    gateway_load_balancer_arns = [aws_lb.region2-gateway_lb.arn]
    tags = {
        Name = "GWLB-SERVICE-${var.region2}"
    }
}

//GWLBE For Security VPC in Region 2 AZ1 
resource "aws_vpc_endpoint" "region2-gwlbendpointsecvpcaz1" {
    provider            = aws.region2

    service_name        = aws_vpc_endpoint_service.region2-fgtgwlbservice.service_name
    subnet_ids          = [aws_subnet.region2-gwlbeaz1.id]
    vpc_endpoint_type   = aws_vpc_endpoint_service.region2-fgtgwlbservice.service_type
    vpc_id              = aws_vpc.region2-sec-vpc.id
    tags = {
        Name = "FortiGate-VM-GWLBE-SECVPC-${var.region2-az1}"
    }
}
//GWLBE For Security VPC Region-2 in AZ2

resource "aws_vpc_endpoint" "region2-gwlbendpointsecvpcaz2" {
    provider            = aws.region2
    service_name        = aws_vpc_endpoint_service.region2-fgtgwlbservice.service_name
    subnet_ids          = [aws_subnet.region2-gwlbeaz2.id]
    vpc_endpoint_type   = aws_vpc_endpoint_service.region2-fgtgwlbservice.service_type
    vpc_id              = aws_vpc.region2-sec-vpc.id
    tags = {
        Name = "FortiGate-VM-GWLBE-SECVPC-${var.region2-az2}"
    }
}
