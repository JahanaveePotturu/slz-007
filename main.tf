terraform {
   required_providers {
      ibm = {
         source = "IBM-Cloud/ibm"
         version = ">= 1.9.0"
      }
    }
    required_version = ">= 0.13"
  }

module "resource_group" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-resource-group.git"
  resource_group_name = var.resource_group_name
  provision           = false
  ibmcloud_api_key    = var.ibmcloud_api_key
}

module "subnets" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-subnets.git"
  resource_group_id = module.resource_group.id
  region            = var.region
  ibmcloud_api_key  = var.ibmcloud_api_key
  vpc_name          = module.vpc.name
  gateways          = []
  _count            = 2
  label             = "vpn"
}

module "vpc" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc.git"
  resource_group_id   = module.resource_group.id
  resource_group_name = module.resource_group.name
  region              = var.region
  name_prefix         = var.name_prefix
  ibmcloud_api_key    = var.ibmcloud_api_key
}

module "vpn-gateways" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpn-gateway.git?ref=initial-version"
  resource_group_id = module.resource_group.id
  region            = var.region
  ibmcloud_api_key  = var.ibmcloud_api_key
  vpc_name          = module.vpc.name
  vpc_subnet_count  = module.subnets.count
  vpc_subnets       = module.subnets.subnets
}

