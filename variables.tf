variable "webservice_names" {
  type = map(string)
  default = {
    devtc = "devtc"
  }
}

variable "db_name" {
  type = string
  default = "devtc"
}

variable "primary_zone_name" {
  type        = string
  description = "The name of your primary zone. All resources will be addressed via this hosted zone."
  default     = "casasky.de"
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

variable "DATABASE_PASSWORD" {
  description = "Sensitive TF_VARIABLE for reading the database password that has to be set during postgres creation"
}