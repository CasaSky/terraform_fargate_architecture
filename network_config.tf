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

resource "aws_vpc" "vpc_main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "sn_00_eu_central_1a_vpc_main" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "172.31.16.0/20"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_01_eu_central_1b_vpc_main" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "172.31.32.0/20"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_02_eu_central_1c_vpc_main" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = "172.31.0.0/20"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt_vpc_main" {
  vpc_id = aws_vpc.vpc_main.id
}

resource "aws_internet_gateway" "gw_vpc_main" {
  vpc_id = aws_vpc.vpc_main.id
}

resource "aws_default_network_acl" "acl_vpc_main" {
  default_network_acl_id = aws_vpc.vpc_main.default_network_acl_id
  subnet_ids = [
    aws_subnet.sn_00_eu_central_1a_vpc_main.id,
    aws_subnet.sn_01_eu_central_1b_vpc_main.id,
    aws_subnet.sn_02_eu_central_1c_vpc_main.id
  ]
  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    icmp_code  = 0
    icmp_type  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }
  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    icmp_code  = 0
    icmp_type  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }
}

resource "aws_default_security_group" "sg" {
  vpc_id      = aws_vpc.vpc_main.id

  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    self = true
  }

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

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 32768
    protocol         = "tcp"
    to_port          = 60999
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 0
    protocol         = "-1"
    self             = false
    to_port          = 0
  }
}

resource "aws_security_group" "sg_earthws_fg" {
  vpc_id      = aws_vpc.vpc_main.id
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
  vpc_id      = aws_vpc.vpc_main.id
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
  vpc_id      = aws_vpc.vpc_main.id
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