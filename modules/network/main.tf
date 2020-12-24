locals {
  www_cidr_block = "0.0.0.0/0"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  # todo check this configuration - this is added due to publicly wanted access of rds
  #enable_dns_hostnames = true
  #enable_dns_support = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_route_table" "main_vpc" {
  vpc_id = aws_vpc.main.id
}

resource "aws_internet_gateway" "main_vpc" {
  vpc_id = aws_vpc.main.id
}

resource "aws_default_security_group" "main_vpc" {
  vpc_id      = aws_vpc.main.id

  egress {
    cidr_blocks      = [local.www_cidr_block]
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
  }

  ingress {
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    self             = true
  }
}

resource "aws_subnet" "sn_00_euc_1a" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.sn_00_cidr_block
  availability_zone = "eu-central-1a"

  tags = {
    Name = "sn-00-euc-1a"
  }
}

resource "aws_subnet" "sn_01_euc_1b" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.sn_01_cidr_block
  availability_zone = "eu-central-1b"

  tags = {
    Name = "sn-01-euc-1b"
  }
}

resource "aws_subnet" "sn_02_euc_1c" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.sn_02_cidr_block
  availability_zone = "eu-central-1c"

  tags = {
    Name = "sn-02-euc-1c"
  }
}

resource "aws_default_network_acl" "main_network" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id
  subnet_ids = [
    aws_subnet.sn_00_euc_1a.id,
    aws_subnet.sn_01_euc_1b.id,
    aws_subnet.sn_02_euc_1c.id
  ]

  egress {
    action     = "allow"
    cidr_block = local.www_cidr_block
    from_port  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }

  ingress {
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }

  ingress {
    action           = "allow"
    cidr_block       = local.www_cidr_block
    from_port        = 32768
    protocol         = "tcp"
    rule_no          = 200
    to_port          = 60999
  }

  ingress {
    action           = "allow"
    cidr_block       = local.www_cidr_block
    from_port        = 80
    protocol         = "tcp"
    rule_no          = 300
    to_port          = 80
  }

  ingress {
    action           = "allow"
    cidr_block       = local.www_cidr_block
    from_port        = 443
    protocol         = "tcp"
    rule_no          = 400
    to_port          = 443
  }
}