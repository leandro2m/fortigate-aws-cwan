
# ---------- GLOBAL NETWORK ----------
resource "aws_networkmanager_global_network" "global_network" {

  description = "Global Network"

  tags = {
    Name = "Global-WAN-Demo"
  }
}

# ---------- CWAN Initial Policy ----------

data "aws_networkmanager_core_network_policy_document" "base_policy" {

  core_network_configuration {
    vpn_ecmp_support    = true
    asn_ranges          = ["64520-65525"]
    # inside_cidr_blocks = "172.22.0.0/16"
    edge_locations {
      location = var.region1
      asn      = 64520
    #   inside_cidr_blocks = "172.22.1.0/24"
    }
    edge_locations {
      location = var.region2
      asn      = 64521
    #   inside_cidr_blocks = "172.22.2.0/16"

    }
  }

  segments {
    name                          = "production"
    description                   = "Production traffic"
    require_attachment_acceptance = false
    isolate_attachments           = true
  }
  segments {
    name                          = "development"
    description                   = "Development traffic"
    require_attachment_acceptance = false
    isolate_attachments           = false
  }
  network_function_groups {
    name                                    = "inspectionVpcs"
    description                             = "Network Function Group with FortiGates"
    require_attachment_acceptance           = false
  }
  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "inspection"
      value    = "true"
    }
    action {
      add_to_network_function_group = "inspectionVpcs"
    }
  }

  attachment_policies {
    rule_number     = 200
    condition_logic = "or"

    conditions {
      type = "tag-exists"
      key  = "domain"
    }
    action {
      association_method = "tag"
      tag_value_of_key   = "domain"
    }
  } 
}
################ Policy ###################

data "aws_networkmanager_core_network_policy_document" "policy" {
  core_network_configuration {
    vpn_ecmp_support    = true
    asn_ranges          = ["64520-64530"]
    # inside_cidr_blocks = "172.22.0.0/16"
    edge_locations {
      location = var.region1
      asn      = 64520
    #   inside_cidr_blocks = "172.22.1.0/24"
    }
    edge_locations {
      location = var.region2
      asn      = 64521
    #   inside_cidr_blocks = "172.22.2.0/16"

    }
  }

  segments {
    name                          = "production"
    description                   = "Production traffic"
    require_attachment_acceptance = false
    isolate_attachments           = true
  }
  segments {
    name                          = "development"
    description                   = "Development traffic"
    require_attachment_acceptance = false
    isolate_attachments           = false
  }
  network_function_groups {
    name                                    = "inspectionVpcs"
    description                             = "Network Function Group with FortiGates"
    require_attachment_acceptance           = false
  }

  segment_actions {
    action  = "send-via"
    segment = "production"
    mode    = "single-hop"

    when_sent_to {
      segments = ["*"]
    }

    via {
      network_function_groups = ["inspectionVpcs"]

     with_edge_override {
          edge_sets     = [[var.region1, var.region2]]
          use_edge_location = var.region1
      }
    }
  }
  segment_actions {
    action  = "send-to"
    segment = "production"
    via {
      network_function_groups = ["inspectionVpcs"]
    }
  }
  segment_actions {
    action  = "send-to"
    segment = "development"
    via {
      network_function_groups = ["inspectionVpcs"]
    }
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "inspection"
      value    = "true"
    }
    action {
      add_to_network_function_group = "inspectionVpcs"
    }
  }

  attachment_policies {
    rule_number     = 200
    condition_logic = "or"

    conditions {
      type = "tag-exists"
      key  = "domain"
    }
    action {
      association_method = "tag"
      tag_value_of_key   = "domain"
    }
  } 
}


# ---------- CORE NETWORK ----------
resource "aws_networkmanager_core_network" "core_network" {

  description       = "Core Network - Demo FortiGate"
  global_network_id = aws_networkmanager_global_network.global_network.id

  create_base_policy   = true
  base_policy_document = data.aws_networkmanager_core_network_policy_document.base_policy.json

  tags = {
    Name = "Core Network Demo FortiGate"
  }
}

#// Core Network Policy Attachment
resource "aws_networkmanager_core_network_policy_attachment" "core_network_policy_attachment" {

  core_network_id = aws_networkmanager_core_network.core_network.id
  policy_document = data.aws_networkmanager_core_network_policy_document.policy.json

  depends_on = [
    aws_networkmanager_vpc_attachment.region1-sec-vpc,
    aws_networkmanager_vpc_attachment.region2-sec-vpc
  ]
}

// Attachment Security-VPC Region1
resource "aws_networkmanager_vpc_attachment" "region1-sec-vpc" {
  depends_on = [aws_networkmanager_core_network.core_network]
  subnet_arns     = [aws_subnet.region1-cwansubnetaz1.arn,aws_subnet.region1-cwansubnetaz2.arn ]
  core_network_id = aws_networkmanager_core_network.core_network.id
  vpc_arn         = aws_vpc.region1-sec-vpc.arn
  options {
      appliance_mode_support  = true
  }
  tags = {inspection = "true", Name = "sec-vpc-region-1"}
}


// Production A Region 1 Attachment
resource "aws_networkmanager_vpc_attachment" "region1-prod-a" {
  depends_on = [aws_networkmanager_core_network.core_network]
  subnet_arns     = [aws_subnet.region1-privatesubnetaz1-prod-a.arn]
  core_network_id = aws_networkmanager_core_network.core_network.id
  vpc_arn         = aws_vpc.region1-vpc-prod-a.arn
  tags = {domain = "production", Name = "prod-a-attachment-${var.region1}"}
}
// Dev A Region 1 Attachment
resource "aws_networkmanager_vpc_attachment" "region1-dev-a" {
  depends_on = [aws_networkmanager_core_network.core_network]
  subnet_arns     = [aws_subnet.region1-privatesubnetaz1-dev-a.arn]
  core_network_id = aws_networkmanager_core_network.core_network.id
  vpc_arn         = aws_vpc.region1-vpc-dev-a.arn
  tags = {domain = "development", Name = "dev-a-attachment-${var.region1}"}
}


//update private route table on Prod-A VPC Region-1
resource "aws_route" "region1-private-prod-a-route-default" {
  provider               = aws.region1
  depends_on             = [aws_networkmanager_vpc_attachment.region1-prod-a]
  route_table_id         = aws_route_table.region1-prod-a-private-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}

//update public route table on Prod-A VPC Region-1
resource "aws_route" "region1-public-prod-a-route-default" {
  provider               = aws.region1
  depends_on             = [aws_networkmanager_vpc_attachment.region1-prod-a]
  route_table_id         = aws_route_table.region1-prod-a-public-rtb.id
  destination_cidr_block = "10.0.0.0/8"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}

//update private route table on Dev-A VPC Region-1
resource "aws_route" "region1-private-dev-a-route-default" {
  provider               = aws.region1
  depends_on             = [aws_networkmanager_vpc_attachment.region1-dev-a]
  route_table_id         = aws_route_table.region1-dev-a-private-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}

//update private route table on Dev-A VPC Region-1
resource "aws_route" "region1-public-dev-a-route-default" {
  provider               = aws.region1
  depends_on             = [aws_networkmanager_vpc_attachment.region1-dev-a]
  route_table_id         = aws_route_table.region1-dev-a-public-rtb.id
  destination_cidr_block = "10.0.0.0/8"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}

//update private route table on Sec-VPC VPC Region-1
resource "aws_route" "region1-private-sec-vpc-route-default" {
  provider               = aws.region1
  depends_on             = [aws_networkmanager_vpc_attachment.region1-sec-vpc]
  route_table_id         = aws_route_table.region1-secvpcprivatertb.id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}

//update gwlb route table on Sec-VPC VPC Region-1
resource "aws_route" "region1-gwlb-rtb-sec-vpc-route-default" {
  provider               = aws.region1
  depends_on             = [aws_networkmanager_vpc_attachment.region1-sec-vpc]
  route_table_id         = aws_route_table.region1-secvpcgwlbertb.id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}


// Attachment Security-VPC Region2
resource "aws_networkmanager_vpc_attachment" "region2-sec-vpc" {
  depends_on = [aws_networkmanager_core_network.core_network]
  subnet_arns     = [aws_subnet.region2-cwansubnetaz1.arn,aws_subnet.region2-cwansubnetaz2.arn ]
  core_network_id = aws_networkmanager_core_network.core_network.id
  vpc_arn         = aws_vpc.region2-sec-vpc.arn
  options {
      appliance_mode_support  = true
  }
  tags = {inspection = "true", Name = "sec-vpc-region-2"}
}


# // Production B Region2 Attachment
resource "aws_networkmanager_vpc_attachment" "region2-prod-b" {
  depends_on = [aws_networkmanager_core_network.core_network]
  subnet_arns     = [aws_subnet.region2-privatesubnetaz1-prod-b.arn]
  core_network_id = aws_networkmanager_core_network.core_network.id
  vpc_arn         = aws_vpc.region2-vpc-prod-b.arn
  tags = {domain = "production", Name = "prod-b-attachment-${var.region2}"}
}

// Dev B Region2 Attachment
resource "aws_networkmanager_vpc_attachment" "region2-dev-b" {
  depends_on = [aws_networkmanager_core_network.core_network]
  subnet_arns     = [aws_subnet.region2-privatesubnetaz1-dev-b.arn]
  core_network_id = aws_networkmanager_core_network.core_network.id
  vpc_arn         = aws_vpc.region2-vpc-dev-b.arn
  tags = {domain = "development", Name = "dev-b-attachment-${var.region2}"}
}

//update private route table on Prod-B VPC Region-2
resource "aws_route" "region2-private-prod-b-route-default" {
  provider               = aws.region2
  depends_on             = [aws_networkmanager_vpc_attachment.region2-prod-b]
  route_table_id         = aws_route_table.region2-prod-b-private-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}

//update private route table on Prod-B VPC Region-2
resource "aws_route" "region2-public-prod-b-route" {
  provider               = aws.region2
  depends_on             = [aws_networkmanager_vpc_attachment.region2-prod-b]
  route_table_id         = aws_route_table.region2-prod-b-public-rtb.id
  destination_cidr_block = "10.0.0.0/8"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}

//update public route table on Dev-B VPC Region-2
resource "aws_route" "region1-public-dev-b-route-default" {
  provider               = aws.region2
  depends_on             = [aws_networkmanager_vpc_attachment.region2-dev-b]
  route_table_id         = aws_route_table.region2-dev-b-public-rtb.id
  destination_cidr_block = "10.0.0.0/8"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}


//update private route table on Sec-VPC VPC Region-2
resource "aws_route" "region2-private-sec-vpc-route-default" {
  provider               = aws.region2
  depends_on             = [aws_networkmanager_vpc_attachment.region2-sec-vpc]
  route_table_id         = aws_route_table.region2-secvpcprivatertb.id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}


//update gwlb route table on Sec-VPC VPC Region-2
resource "aws_route" "region2-gwlb-rtb-sec-vpc-route-default" {
  provider               = aws.region2
  depends_on             = [aws_networkmanager_vpc_attachment.region2-sec-vpc]
  route_table_id         = aws_route_table.region2-secvpcgwlbertb.id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.core_network.arn
}

