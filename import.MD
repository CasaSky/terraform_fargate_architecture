## in order to import existing aws resources for the first time in the terraform remote state, use the terraform import command for each of the existing resources  
## as a result, terraform will adapt the configuration infrastructure code with the state file
```
terraform import module.network_default.aws_vpc.vpc_main vpc-1309b479
terraform import module.network_default.aws_subnet.sn_00_eu_central_1a_vpc_main subnet-86a2c6ec
terraform import module.network_default.aws_subnet.sn_01_eu_central_1b_vpc_main subnet-b63be8ca
terraform import module.network_default.aws_subnet.sn_02_eu_central_1c_vpc_main subnet-5a208616
terraform import module.network_default.aws_route_table.rt_vpc_main rtb-484a7c22
terraform import module.network_default.aws_internet_gateway.gw_vpc_main igw-33f14258
terraform import module.network_default.aws_default_network_acl.acl_vpc_main acl-e2206988
terraform import module.network_default.aws_default_security_group.sg sg-ef151793
terraform import aws_security_group.sg_earthws_fg sg-09bb7a7fc282dd76a
terraform import aws_security_group.sg_earthws_fg_alb sg-03720024b8a3410d0
terraform import aws_security_group.sg_template_rds sg-02bf3d259793d9b1b
```
