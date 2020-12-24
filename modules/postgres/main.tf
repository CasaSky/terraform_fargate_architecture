resource "aws_security_group" "template_rds" {
  vpc_id      = var.vpc_id
  name        = format("%s-sg", var.db_instance_identifier)
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

resource "aws_db_instance" "postgres" {
  identifier             = var.db_instance_identifier
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "12.4"
  instance_class         = "db.t2.micro"
  max_allocated_storage  = 1000
  username               = "postgres"
  password               = var.password
  vpc_security_group_ids = [aws_security_group.template_rds.id, var.default_sg_id]
  iam_database_authentication_enabled = true
  copy_tags_to_snapshot = true
  performance_insights_enabled = true
  publicly_accessible = true
  skip_final_snapshot = true
}