variable "primary_zone_name" {
  default = "casasky.de"
}

variable "vpc_cidr_block" {
  default = "172.31.0.0/16"
}

variable "sn_00_cidr_block" {
  default = "172.31.16.0/20"
}

variable "sn_01_cidr_block" {
  default = "172.31.32.0/20"
}

variable "sn_02_cidr_block" {
  default = "172.31.0.0/20"
}

variable "SPRING_DATASOURCE_PASSWORD" {
  description = "TF_VARIABLE where the webservice datasource password is set"
}

variable "LOG_SENTRY_DSN" {
  description = "TF_VARIABLE where the sentry dsn url is set"
}