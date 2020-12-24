variable "db_instance_identifier" {
  description = "The identifier or name for the managed postgres instance to create"
  type = string
}

variable "vpc_id" {
  description = "The vpc id of the network"
  type = string
}

variable "default_sg_id" {
  description = "The default sg id of the network"
  type = string
}

variable "default_network_subnet_ids" {
  description = "The subnet ids of the default network"
  type = list(string)
}

variable "password" {
  type = string
}