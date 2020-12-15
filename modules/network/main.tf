resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "sn_00_euc_1a_default_vpc" {
  vpc_id = aws_vpc.default.id
  cidr_block = var.sn_00_cidr_block
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_01_euc_1b_default_vpc" {
  vpc_id = aws_vpc.default.id
  cidr_block = var.sn_01_cidr_block
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_02_euc_1c_default_vpc" {
  vpc_id = aws_vpc.default.id
  cidr_block = var.sn_02_cidr_block
  map_public_ip_on_launch = true
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

resource "aws_default_security_group" "default_vpc" {
  vpc_id      = aws_vpc.default.id

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