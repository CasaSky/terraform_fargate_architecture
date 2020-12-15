## in order to import existing aws resources for the first time in the terraform remote state, use the terraform import command for each of the existing resources  
## as a result, terraform will adapt the configuration infrastructure code with the state file
```
terraform import module.network_default.aws_vpc.default vpc-1309b479
terraform import module.network_default.aws_subnet.sn_00_euc_1a_default_vpc subnet-86a2c6ec
terraform import module.network_default.aws_subnet.sn_01_euc_1b_default_vpc subnet-b63be8ca
terraform import module.network_default.aws_subnet.sn_02_euc_1c_default_vpc subnet-5a208616
terraform import module.network_default.aws_route_table.default_vpc rtb-484a7c22
terraform import module.network_default.aws_internet_gateway.default_vpc igw-33f14258
terraform import module.network_default.aws_default_network_acl.default_vpc acl-e2206988
terraform import module.network_default.aws_default_security_group.default_vpc sg-ef151793
terraform import module.webservice_earth.module.alb_certificate.aws_acm_certificate.cert arn:aws:acm:eu-central-1:182355820400:certificate/a2bc7f64-03a5-42d0-a021-da8210850018
terraform import module.webservice_earth.aws_security_group.service sg-09bb7a7fc282dd76a
terraform import module.webservice_earth.aws_security_group.alb sg-03720024b8a3410d0
terraform import module.webservice_earth.aws_lb.service arn:aws:elasticloadbalancing:eu-central-1:182355820400:loadbalancer/app/earthws-fg-alb/0421c17ee9d9b607
terraform import module.webservice_earth.aws_lb_target_group.alb arn:aws:elasticloadbalancing:eu-central-1:182355820400:targetgroup/earthws-fg-alb-tg/3917cdae33fb8ec3
terraform import module.webservice_earth.aws_lb_listener.alb arn:aws:elasticloadbalancing:eu-central-1:182355820400:listener/app/earthws-fg-alb/0421c17ee9d9b607/07371cc9a5e0e566
terraform import module.webservice_earth.aws_lb_listener.ssl_alb arn:aws:elasticloadbalancing:eu-central-1:182355820400:listener/app/earthws-fg-alb/0421c17ee9d9b607/15107090b045f7ba
terraform import module.webservice_earth.aws_iam_role.task_definition earthws-fg-task-def-role
terraform import module.webservice_earth.aws_ecs_task_definition.ecs arn:aws:ecs:eu-central-1:182355820400:task-definition/earthws-fg-task-def:7
terraform import module.webservice_earth.aws_ecr_repository.ecs earthws
terraform import module.webservice_earth.aws_ecs_cluster.ecs earthws-fg-cluster
terraform import module.webservice_earth.aws_ecs_service.ecs earthws-fg-cluster/earthws-fg-service
terraform import aws_route53_zone.primary Z01653637OSY7TQPY7UK
terraform import aws_security_group.template_rds sg-02bf3d259793d9b1b
```
