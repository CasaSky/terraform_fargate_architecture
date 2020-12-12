terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "casasky"

    workspaces {
      name = "template_project"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
}

module "network_default" {
  source = "./modules/network/"
  vpc_cidr_block = var.vpc_cidr_block
  sn_00_cidr_block = var.sn_00_cidr_block
  sn_01_cidr_block = var.sn_01_cidr_block
  sn_02_cidr_block = var.sn_02_cidr_block
}

module "cert_alb" {
  source = "./modules/cert/"
  domain_name = "earthws.alb.casasky.de"
  validation_method = "DNS"
  tags = {
    application = "earthws"
  }
}

resource "aws_security_group" "sg_earthws_fg" {
  vpc_id      = module.network_default.vpc_default_id
  name        = "earthws-fg-sg"
  description = "fargate sg"

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "provisory (change to local net or fix ip)"
    from_port        = 22
    protocol         = "tcp"
    to_port          = 22
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "provisory (change to local net or fix ip)"
    from_port        = 9090
    protocol         = "tcp"
    to_port          = 9090
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 0
    protocol         = "-1"
    self             = false
    to_port          = 0
  }
}

resource "aws_security_group" "sg_earthws_fg_alb" {
  vpc_id      = module.network_default.vpc_default_id
  name        = "earthws-fg-alb-sg"
  description = "sg for alb"

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 80
    protocol         = "tcp"
    to_port          = 80
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 443
    protocol         = "tcp"
    to_port          = 443
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 0
    protocol         = "-1"
    self             = false
    to_port          = 0
  }
}

resource "aws_security_group" "sg_template_rds" {
  vpc_id      = module.network_default.vpc_default_id
  name        = "template-db-sg"
  description = "allow public psql"

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 5432
    protocol         = "tcp"
    to_port          = 5432
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 5432
    protocol         = "tcp"
    self             = false
    to_port          = 5432
  }
}

resource "aws_lb" "alb_earthws_fg" {
  name               = "earthws-fg-alb"
  load_balancer_type = "application"
  security_groups    = [module.network_default.sg_default_id, aws_security_group.sg_earthws_fg_alb.id]
  subnets            = module.network_default.subnet_ids
}

resource "aws_lb_target_group" "target_group_alb_earthws_fg" {
  name     = "earthws-fg-alb-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = module.network_default.vpc_default_id
}

resource "aws_lb_listener" "listener_alb_earthws_fg" {
  load_balancer_arn = aws_lb.alb_earthws_fg.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_alb_earthws_fg.arn
  }
}

resource "aws_lb_listener" "ssl_listener_alb_earthws_fg" {
  load_balancer_arn = aws_lb.alb_earthws_fg.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-central-1:182355820400:certificate/a2bc7f64-03a5-42d0-a021-da8210850018"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_alb_earthws_fg.arn
  }
}

# This resource is for additional certificates and does not replace the default certificate on the listener.
resource "aws_lb_listener_certificate" "listener_cert_ssl" {
  listener_arn    = aws_lb_listener.ssl_listener_alb_earthws_fg.arn
  certificate_arn = module.cert_alb.arn
}