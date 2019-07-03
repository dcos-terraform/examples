provider "azure" {}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  ssh_public_key_file               = "~/.ssh/id_rsa.pub"
  cluster_name                      = "gpuinst-dcos-ee-demo"
  dcos_license_key_contents         = "${file("~/license.txt")}"
  dcos_instance_os                  = "centos_7.6"
  dcos_variant                      = "ee"
  dcos_version                      = "1.13.2"
  location                          = "West US 2"
  avset_platform_fault_domain_count = 2
}

module "dcos" {
  source  = "dcos-terraform/dcos/azurerm"
  version = "~> 0.2.0"

  providers = {
    azure = "azure"
  }

  location                          = "${local.location}"
  avset_platform_fault_domain_count = "${local.avset_platform_fault_domain_count}"

  cluster_name        = "${local.cluster_name}"
  ssh_public_key_file = "${local.ssh_public_key_file}"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = 1
  num_private_agents = 0
  num_public_agents  = 0

  dcos_instance_os = "${local.dcos_instance_os}"

  dcos_variant              = "${local.dcos_variant}"
  dcos_version              = "${local.dcos_version}"
  dcos_license_key_contents = "${local.dcos_license_key_contents}"

  # provide a SHA512 hashed password, here "deleteme"
  dcos_superuser_password_hash = "$6$rounds=656000$YSvuFmasQDXheddh$TpYlCxNHF6PbsGkjlK99Pwxg7D0mgWJ.y0hE2JKoa61wHx.1wtxTAHVRHfsJU9zzHWDoE08wpdtToHimNR9FJ/"
  dcos_superuser_username      = "demo-super"

  additional_private_agent_ips = ["${module.gpuagent.private_ips}"]
}

module "gpuagent" {
  source  = "dcos-terraform/private-agents/azurerm"
  version = "~> 0.2.0"

  providers = {
    azure = "azure"
  }

  location                          = "${local.location}"
  avset_platform_fault_domain_count = "${local.avset_platform_fault_domain_count}"

  dcos_instance_os = "${local.dcos_instance_os}"
  public_ssh_key   = "${local.ssh_public_key_file}"
  vm_size          = "Standard_NV6"

  cluster_name              = "${local.cluster_name}"
  hostname_format           = "gpuinstpriv-%[1]d-%[2]s"
  resource_group_name       = "${module.dcos.infrastructure.resource_group_name}"
  subnet_id                 = "${module.dcos.infrastructure.subnet_id}"
  network_security_group_id = "${module.dcos.infrastructure.private_agents.nsg_id}"
  admin_username            = "${module.dcos.infrastructure.private_agents.admin_username}"

  num_private_agents = 1
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}
