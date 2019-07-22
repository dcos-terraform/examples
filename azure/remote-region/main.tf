provider "azure" {}

data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

// lets define variables which are shared between all regions
locals {
  ssh_public_key_file       = "~/.ssh/id_rsa.pub"
  cluster_name              = "rtest-dcos-ee-demo"
  dcos_license_key_contents = "${file("~/license.txt")}"
  dcos_instance_os          = "centos_7.6"
  dcos_variant              = "ee"
  dcos_version              = "1.13.2"

  region_networks = {
    // dont use 172.17/26 as its used by docker.
    "master"    = "172.12.0.0/16" // this is the default
    "West US 2" = "172.13.0.0/16"
    "East US"   = "172.14.0.0/16"
  }
}

############################################################
# main region holding masters
############################################################
module "dcos" {
  source  = "dcos-terraform/dcos/azurerm"
  version = "~> 0.2.0"

  providers = {
    azure = "azure"
  }

  location                          = "West US"
  avset_platform_fault_domain_count = 3
  subnet_range                      = "${local.region_networks["master"]}"

  cluster_name        = "${local.cluster_name}"
  ssh_public_key_file = "${local.ssh_public_key_file}"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = 1
  num_private_agents = 1
  num_public_agents  = 1

  dcos_instance_os          = "${local.dcos_instance_os}"
  dcos_variant              = "${local.dcos_variant}"
  dcos_version              = "${local.dcos_version}"
  dcos_license_key_contents = "${local.dcos_license_key_contents}"

  # provide a SHA512 hashed password, here "deleteme"
  dcos_superuser_password_hash = "$6$rounds=656000$YSvuFmasQDXheddh$TpYlCxNHF6PbsGkjlK99Pwxg7D0mgWJ.y0hE2JKoa61wHx.1wtxTAHVRHfsJU9zzHWDoE08wpdtToHimNR9FJ/"
  dcos_superuser_username      = "demo-super"

  # add additional agents to install run
  additional_private_agent_ips = ["${concat(module.dcos-wus2.private_agents.private_ips,module.dcos-eus.private_agents.private_ips)}"]
}

############################################################
# West US 2 region having agents
############################################################
module "dcos-wus2" {
  source  = "dcos-terraform/infrastructure/azurerm"
  version = "~> 0.2.0"

  providers = {
    azure = "azure"
  }

  location                          = "West US 2"
  avset_platform_fault_domain_count = 2
  subnet_range                      = "${local.region_networks["West US 2"]}"

  admin_ips   = ["${data.http.whatismyip.body}/32"]
  name_prefix = "wus2"

  cluster_name = "${local.cluster_name}"

  num_bootstrap      = 0
  num_masters        = 0
  num_private_agents = 1
  num_public_agents  = 0

  infra_dcos_instance_os = "${local.dcos_instance_os}"
  ssh_public_key_file    = "${local.ssh_public_key_file}"
}

module "vnet-connection-master-wus2" {
  source  = "dcos-terraform/vnet-peering/azurerm"
  version = "~> 0.2.0"

  providers = {
    azure = "azure"
  }

  cluster_name               = "${local.cluster_name}"
  local_region_network       = "master"
  local_resource_group_name  = "${module.dcos.infrastructure.resource_group_name}"
  local_vnet_name            = "${module.dcos.infrastructure.vnet_name}"
  local_vnet_id              = "${module.dcos.infrastructure.vnet_id}"
  remote_region_network      = "wus2"
  remote_resource_group_name = "${module.dcos-wus2.resource_group_name}"
  remote_vnet_name           = "${module.dcos-wus2.vnet_name}"
  remote_vnet_id             = "${module.dcos-wus2.vnet_id}"
}

############################################################
# East US region having agents
############################################################
module "dcos-eus" {
  source  = "dcos-terraform/infrastructure/azurerm"
  version = "~> 0.2.0"

  providers = {
    azure = "azure"
  }

  location                          = "East US"
  avset_platform_fault_domain_count = 3
  subnet_range                      = "${local.region_networks["East US"]}"

  admin_ips   = ["${data.http.whatismyip.body}/32"]
  name_prefix = "eus"

  cluster_name = "${local.cluster_name}"

  num_bootstrap      = 0
  num_masters        = 0
  num_private_agents = 1
  num_public_agents  = 0

  infra_dcos_instance_os = "${local.dcos_instance_os}"
  ssh_public_key_file    = "${local.ssh_public_key_file}"
}

module "vnet-connection-master-eus" {
  source  = "dcos-terraform/vnet-peering/azurerm"
  version = "~> 0.2.0"

  providers = {
    azure = "azure"
  }

  cluster_name               = "${local.cluster_name}"
  local_region_network       = "master"
  local_resource_group_name  = "${module.dcos.infrastructure.resource_group_name}"
  local_vnet_name            = "${module.dcos.infrastructure.vnet_name}"
  local_vnet_id              = "${module.dcos.infrastructure.vnet_id}"
  remote_region_network      = "eus"
  remote_resource_group_name = "${module.dcos-eus.resource_group_name}"
  remote_vnet_name           = "${module.dcos-eus.vnet_name}"
  remote_vnet_id             = "${module.dcos-eus.vnet_id}"
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}
