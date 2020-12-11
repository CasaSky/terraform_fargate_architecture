## in order to import existing aws resources for the first time in the terraform remote state, use the terraform import command for each of the existing resource
## as result, terraform will adapt the configuration infrastructure code with the state file
```
terraform import aws_vpc.vpc_main vpc-1309b479
terraform import aws_subnet.sn_00_eu_central_1a_vpc_main subnet-86a2c6ec
terraform import aws_subnet.sn_01_eu_central_1b_vpc_main subnet-b63be8ca
terraform import aws_subnet.sn_02_eu_central_1c_vpc_main subnet-5a208616
terraform import aws_route_table.rt_vpc_main rtb-484a7c22
terraform import aws_internet_gateway.gw_vpc_main igw-33f14258
terraform import aws_default_network_acl.acl_vpc_main acl-e2206988
terraform import aws_default_security_group.sg sg-ef151793
```