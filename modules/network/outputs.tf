output "vpc_default_id" {
  description = "delivers the created default vpc id"
  value = aws_vpc.default.id
}

output "sg_default_id" {
  description = "delivers the network default security group"
  value = aws_default_security_group.default_vpc.id
}

output "subnet_ids" {
  description = "delivers all network subnet ids"
  value = [aws_subnet.sn_00_euc_1a_default_vpc.id, aws_subnet.sn_01_euc_1b_default_vpc.id, aws_subnet.sn_02_euc_1c_default_vpc.id]
}