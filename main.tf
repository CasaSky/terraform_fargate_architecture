terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "casasky" # change to your specific organization name

    workspaces {
      name = "terraform_fargate_architecture" # change to your specific project name
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
}

locals {
  WEBSERVICE = {
    ENVIRONMENT = {
      FG-TEST = "fg-test"
    }
    SENTRY_ENVIRONMENT = "SENTRY_ENVIRONMENT"
    SPRING_PROFILES_ACTIVE = "SPRING_PROFILES_ACTIVE"
    LOG_SENTRY_DSN = "log.sentry.dsn"
    SPRING_DATASOURCE_PASSWORD = "SPRING_DATASOURCE_PASSWORD"
  }
}

module "network_default" {
  source = "./modules/network/"
  vpc_cidr_block = var.vpc_cidr_block
  sn_00_cidr_block = var.sn_00_cidr_block
  sn_01_cidr_block = var.sn_01_cidr_block
  sn_02_cidr_block = var.sn_02_cidr_block
}

module "main_db" {
  source = "./modules/postgres/"
  db_instance_identifier = var.db_instance_identifier
  password               = var.DATABASE_PASSWORD
  vpc_id                 = module.network_default.vpc_main_id
  default_sg_id          = module.network_default.sg_default_id
  default_network_subnet_ids = module.network_default.subnet_ids
}

module "webservice" {
  source              = "./modules/webservice/"
  for_each            = var.webservice_names
  webservice_name     = each.value
  vpc_id              = module.network_default.vpc_main_id
  default_sg_id       = module.network_default.sg_default_id
  subnet_ids          = module.network_default.subnet_ids
  primary_zone_name   = data.aws_route53_zone.primary.name
  primary_zone_id     = data.aws_route53_zone.primary.id
}

data "aws_route53_zone" "primary" {
  name = var.primary_zone_name
}