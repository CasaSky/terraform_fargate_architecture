output "vpc_default_id" {
  description = "delivers the created default vpc id"
  value = aws_vpc.vpc_main.id
}

output "sg_default_id" {
  description = "delivers the network default security group"
  value = aws_default_security_group.sg.id
}

output "subnet_ids" {
  description = "delivers all network subnet ids"
  value = [aws_subnet.sn_00_eu_central_1a_vpc_main.id, aws_subnet.sn_01_eu_central_1b_vpc_main.id, aws_subnet.sn_02_eu_central_1c_vpc_main.id]
}