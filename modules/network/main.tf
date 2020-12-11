resource "aws_vpc" "vpc_main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "sn_00_eu_central_1a_vpc_main" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = var.sn_00_cidr_block
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_01_eu_central_1b_vpc_main" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = var.sn_01_cidr_block
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_02_eu_central_1c_vpc_main" {
  vpc_id = aws_vpc.vpc_main.id
  cidr_block = var.sn_02_cidr_block
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