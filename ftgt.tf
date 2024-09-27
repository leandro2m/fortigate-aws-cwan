###############FortiGate-VM Region-1###############

resource "aws_network_interface" "region1-eth0" {
    provider            = aws.region1
    description         = "${var.region1}-ftgt-active-port1"
    subnet_id           = aws_subnet.region1-publicsubnetaz1.id
    private_ips         = [cidrhost(aws_subnet.region1-publicsubnetaz1.cidr_block, 10)]
    source_dest_check   = false
    tags = {
        Name = "${var.region1}-ftgt-active-port1"
    }
}

resource "aws_network_interface" "region1-eth1" {
    provider            = aws.region1
    description       = "${var.region1}-ftgt-active-port2"
    subnet_id         = aws_subnet.region1-privatesubnetaz1.id
    private_ips       = [cidrhost(aws_subnet.region1-privatesubnetaz1.cidr_block, 10)]
    source_dest_check = false
    tags = {
        Name = "${var.region1}-ftgt-active-port2"
    }
}

resource "aws_network_interface_sg_attachment" "region1-publicattachment" {
    provider            = aws.region1
    depends_on           = [aws_network_interface.region1-eth0]
    security_group_id    = aws_security_group.region1-allow_all.id
    network_interface_id = aws_network_interface.region1-eth0.id
}

resource "aws_network_interface_sg_attachment" "region1-internalattachment" {
    provider            = aws.region1
    depends_on           = [aws_network_interface.region1-eth1]
    security_group_id    = aws_security_group.region1-allow_all.id
    network_interface_id = aws_network_interface.region1-eth1.id
}

resource "aws_eip" "region1-publicip" {
    provider            = aws.region1
    domain            = "vpc"
    network_interface = aws_network_interface.region1-eth0.id
    tags = {
    Name = "${var.region1}-FTGT-Public-IP"
  }
}

resource "aws_instance" "region1-fgtactive" {
    provider            = aws.region1

  //it will use region, architect, and license type to decide which ami to use for deployment
    ami               = var.fgtami[var.region1][var.arch][var.license_type]
    instance_type     = var.size
    availability_zone = var.region1-az1
    key_name          = var.region1-keyname
    
    user_data = templatefile("${var.bootstrap}", {
        type            = var.license_type
        license_file    = "${var.region1-license}"
        format          = "${var.license_format}"
        region          = var.region1
        port1_ip        = "${cidrhost(aws_subnet.region1-publicsubnetaz1.cidr_block, 10)}"
        port1_mask      = "255.255.255.0"
        port2_ip        = "${cidrhost(aws_subnet.region1-privatesubnetaz1.cidr_block, 10)}"
        port2_mask      = "255.255.255.0"
        port1_gw        = cidrhost(aws_subnet.region1-publicsubnetaz1.cidr_block, 1)
        port2_gw        = cidrhost(aws_subnet.region1-privatesubnetaz1.cidr_block, 1)
        gwlbe_az1       = data.aws_network_interface.region1-gwlbe-az1.private_ip
        gwlbe_az2       = data.aws_network_interface.region1-gwlbe-az2.private_ip

    })

    iam_instance_profile = aws_iam_instance_profile.ftgt_profile.name

    root_block_device {
        volume_type = "standard"
        volume_size = "2"
    }

    ebs_block_device {
        device_name = "/dev/sdb"
        volume_size = "30"
        volume_type = "standard"
    }

    network_interface {
        network_interface_id = aws_network_interface.region1-eth0.id
        device_index         = 0
    }

    network_interface {
        network_interface_id = aws_network_interface.region1-eth1.id
        device_index         = 1
    }

    tags = {
        Name = "FortiGateVM-1-${var.region1-az1}"
    }
}



###############FortiGate-VM Region-2###############

resource "aws_network_interface" "region2-eth0" {
    provider            = aws.region2
    description         = "${var.region2}-ftgt-active-port2"
    subnet_id           = aws_subnet.region2-publicsubnetaz1.id
    private_ips         = [cidrhost(aws_subnet.region2-publicsubnetaz1.cidr_block, 10)]
    source_dest_check   = false
    tags = {
        Name = "${var.region2}-ftgt-active-port1"
    }
}

resource "aws_network_interface" "region2-eth1" {
    provider            = aws.region2
    description       = "${var.region2}-ftgt-active-port2"
    subnet_id         = aws_subnet.region2-privatesubnetaz1.id
    private_ips       = [cidrhost(aws_subnet.region2-privatesubnetaz1.cidr_block, 10)]
    source_dest_check = false
    tags = {
        Name = "${var.region2}-ftgt-active-port2"
    }
}

resource "aws_network_interface_sg_attachment" "region2-publicattachment" {
    provider             = aws.region2
    depends_on           = [aws_network_interface.region2-eth0]
    security_group_id    = aws_security_group.region2-allow_all.id
    network_interface_id = aws_network_interface.region2-eth0.id
}

resource "aws_network_interface_sg_attachment" "region2-internalattachment" {
    provider             = aws.region2
    depends_on           = [aws_network_interface.region2-eth1]
    security_group_id    = aws_security_group.region2-allow_all.id
    network_interface_id = aws_network_interface.region2-eth1.id
}

resource "aws_eip" "region2-publicip" {
    provider            = aws.region2
    domain              = "vpc"
    network_interface   = aws_network_interface.region2-eth0.id
    tags = {
    Name = "${var.region2}-FTGT-Public-IP"
  }
}

resource "aws_instance" "region2-fgtactive" {
    provider            = aws.region2

  //it will use region, architect, and license type to decide which ami to use for deployment
    ami               = var.fgtami[var.region2][var.arch][var.license_type]
    instance_type     = var.size
    availability_zone = var.region2-az1
    key_name          = var.region2-keyname
    user_data = templatefile("${var.bootstrap}", {
        type            = var.license_type
        license_file    = "${var.region2-license}"
        format          = "${var.license_format}"
        region          = var.region2
        port1_ip        = "${cidrhost(aws_subnet.region2-publicsubnetaz1.cidr_block, 10)}"
        port1_mask      = "255.255.255.0"
        port2_ip        = "${cidrhost(aws_subnet.region2-privatesubnetaz1.cidr_block, 10)}"
        port2_mask      = "255.255.255.0"
        port1_gw        = cidrhost(aws_subnet.region2-publicsubnetaz1.cidr_block, 1)
        port2_gw        = cidrhost(aws_subnet.region2-privatesubnetaz1.cidr_block, 1)
        gwlbe_az1       = data.aws_network_interface.region2-gwlbe-az1.private_ip
        gwlbe_az2       = data.aws_network_interface.region2-gwlbe-az2.private_ip
    })

    iam_instance_profile = aws_iam_instance_profile.ftgt_profile.name

    root_block_device {
        volume_type = "standard"
        volume_size = "2"
    }

    ebs_block_device {
        device_name = "/dev/sdb"
        volume_size = "30"
        volume_type = "standard"
    }

    network_interface {
        network_interface_id = aws_network_interface.region2-eth0.id
        device_index         = 0
    }

    network_interface {
        network_interface_id = aws_network_interface.region2-eth1.id
        device_index         = 1
    }

    tags = {
        Name = "FortiGateVM-1-${var.region2-az1}"
    }
}