output "vpc_default_id" {
  description = "delivers the created default vpc id"
  value = aws_vpc.vpc_main.id
}