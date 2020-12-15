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

variable "image" {
  type        = string
  description = "(Required) The source of the image that will be used for the container"
  default = "182355820400.dkr.ecr.eu-central-1.amazonaws.com/earthws"
}

variable "cpu" {
  type        = number
  description = " (Required for FARGATE) The number of cpu units used by the task"
  default     = 256
}

variable "memory" {
  type        = number
  description = " (Required for FARGATE) The number of memory units used by the task"
  default     = 512
}

variable "essential" {
  type        = bool
  description = ""
  default = true
}

variable "port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  description = "The available port mappings for the started container"
  default = [{
    containerPort = 9090
    hostPort = 9090
    protocol = "tcp"
  }]
}

variable "environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "(Required) The environment variables that has to be configured while starting the container"
}

variable "log_configuration" {
  type = object({
    logDriver = string
    options = object({
      awslogs-group         = string
      awslogs-region        = string
      awslogs-stream-prefix = string
    })
  })

  description = "The available port mappings for the started container"
  default = {
    logDriver = "awslogs",
    options = {
      awslogs-group         = "/ecs/earthws-fg-task-def"
      awslogs-region        = "eu-central-1"
      awslogs-stream-prefix = "ecs"
    }
  }
}

variable "default_vpc_id" {
  type = string
  description = "(Required) The default vpc id associated with the load balancer"
}
variable "default_sg_id" {
  type = string
  description = "(Required) The default security group for the vpc associated with the service"
}

variable "subnet_ids" {
  type = list(string)
  description = "(Required) The subnets associated with the task or service"
}