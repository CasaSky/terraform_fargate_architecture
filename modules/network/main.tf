locals {
  www_cidr_block = "0.0.0.0/0"
}

resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "sn_00_euc_1a_default_vpc" {
  vpc_id = aws_vpc.default.id
  cidr_block = var.sn_00_cidr_block
}

resource "aws_subnet" "sn_01_euc_1b_default_vpc" {
  vpc_id = aws_vpc.default.id
  cidr_block = var.sn_01_cidr_block
}

resource "aws_subnet" "sn_02_euc_1c_default_vpc" {
  vpc_id = aws_vpc.default.id
  cidr_block = var.sn_02_cidr_block
}

resource "aws_route_table" "default_vpc" {
  vpc_id = aws_vpc.default.id
}

resource "aws_internet_gateway" "default_vpc" {
  vpc_id = aws_vpc.default.id
}

resource "aws_default_network_acl" "default_vpc" {
  default_network_acl_id = aws_vpc.default.default_network_acl_id
  subnet_ids = [
    aws_subnet.sn_00_euc_1a_default_vpc.id,
    aws_subnet.sn_01_euc_1b_default_vpc.id,
    aws_subnet.sn_02_euc_1c_default_vpc.id
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
    cidr_block = aws_vpc.default.cidr_block
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

resource "aws_default_security_group" "default_vpc" {
  vpc_id      = aws_vpc.default.id

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