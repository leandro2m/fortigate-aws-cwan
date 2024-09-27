# # output "subnet-public-az1" {
# #   description = "subnet-public-az1."
# #   value       = aws_subnet.publicsubnetaz1.cidr_block
# # }

# # output "public-ip-ftgt-1" {
# #   description = "public-ip-ftgt."
# #   value       = cidrhost(aws_subnet.publicsubnetaz1.cidr_block, 10)
# # }
# # output "private-ip-ftgt-1" {
# #   description = "private-ip-ftgt."
# #   value       = cidrhost(aws_subnet.privatesubnetaz1.cidr_block, 10)
# # }

# output "Mgmt-IP-ftgt-Active" {
#   description = "MGMT-IP-FTGT-Active."
#   value       = aws_eip.MGMTPublicIP.public_ip

# }

# # output "Mgmt-IP-ftgt-Passive" {
# #   description = "MGMT-IP-FTGT-Passive."
# #   value       = aws_eip.passiveMGMTPublicIP.public_ip

# # }



