terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "casasky"

    workspaces {
      name = "template_project"
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
    NAMES = {
      EARTH_WS = "earthws"
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

module "template_db" {
  source = "./modules/postgres/"
  db_instance_identifier = "template-db"
  default_vpc_id         = module.network_default.vpc_default_id
  default_sg_id          = module.network_default.sg_default_id
}

module "webservice_earth" {
  source              = "./modules/webservice/"
  webservice_name     = local.WEBSERVICE.NAMES.EARTH_WS
  default_vpc_id      = module.network_default.vpc_default_id
  default_sg_id       = module.network_default.sg_default_id
  subnet_ids          = module.network_default.subnet_ids
  primary_zone_name   = aws_route53_zone.primary.name
  primary_zone_id     = aws_route53_zone.primary.id
  datasource_password = var.SPRING_DATASOURCE_PASSWORD
  sentry_dsn          = var.LOG_SENTRY_DSN
}

resource "aws_route53_zone" "primary" {
  name    = var.primary_zone_name
  comment = "HostedZone created by Route53 Registrar"
}