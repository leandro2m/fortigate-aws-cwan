resource "aws_iam_role_policy" "userpolicy" {
  name = "FTGT-Policy-Terraform"
  role = aws_iam_role.ftgt-role.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:Describe*",
                "ec2:AssociateAddress",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses",
                "ec2:ReplaceRoute"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ftgt-role" {
  name = "ftgt_role_ha_1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      Name = "ftgt_role_ha_1"
  }
}

resource "aws_iam_instance_profile" "ftgt_profile" {
  name = "ftgtroleha_1"
  role = "${aws_iam_role.ftgt-role.name}"
}

