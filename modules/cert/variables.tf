variable "domain_name" {
  description = "domain name for the desired certification"
  type = string
}

variable "validation_method" {
  description = "certificate validation method"
  type = string
}

variable "tags" {
  description = "certificate tags"
  type  = object({
    application = string
  })
}