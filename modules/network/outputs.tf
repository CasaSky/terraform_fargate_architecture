output "vpc_main_id" {
  description = "delivers the id of the created vpc"
  value = aws_vpc.main.id
}

output "sg_default_id" {
  description = "delivers the network default security group"
  value = aws_default_security_group.main_vpc.id
}

output "subnet_ids" {
  description = "delivers all network subnet ids"
  value = [aws_subnet.sn_00_euc_1a.id, aws_subnet.sn_01_euc_1b.id, aws_subnet.sn_02_euc_1c.id]
}