variable "webservice_name" {
  type = string
  description = "(Required) The name of the webservice that will be created as fargate cluster"
}

variable "primary_zone_name" {
  type = string
  description = "(Required) The name of the primary hosted zone"
}

variable "primary_zone_id" {
  type = string
  description = "(Required) The id of the primary hosted zone"
}

variable "vpc_id" {
  type = string
  description = "(Required) The id of the vpc associated with the load balancer"
}

variable "default_sg_id" {
  type = string
  description = "(Required) The default security group for the vpc associated with the service"
}

variable "subnet_ids" {
  type = list(string)
  description = "(Required) The subnets associated with the task or service"
}

variable "datasource_password" {
  description = "The webservice datasource password"
}

variable "sentry_dsn" {
  description = "The sentry dsn url"
}