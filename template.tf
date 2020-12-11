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