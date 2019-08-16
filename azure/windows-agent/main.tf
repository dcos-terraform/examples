provider "azurerm" {}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  cluster_name     = "demo52"
  location         = "northeurope"
  dcos_version     = "1.13.3"
  dcos_variant     = "open"
  dcos_instance_os = "centos_7.6"
  dcos_winagent_os = "windows_1809"
  vm_size          = "Standard_D2s_v3"
  ssh_public_key_file = "~/.ssh/aws-meso-wind.pub"
}

module "dcos" {
  source  = "dcos-terraform/dcos/azurerm"
  version = "~> 0.2.0"

  providers = {
    azurerm = "azurerm"
  }

  location = "${local.location}"

  cluster_name        = "${local.cluster_name}"
  ssh_public_key_file = "${local.ssh_public_key_file}"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = "3"
  num_private_agents = "1"
  num_public_agents  = "1"

  bootstrap_vm_size      = "Standard_B2ms"
  masters_vm_size        = "${local.vm_size}"
  private_agents_vm_size = "${local.vm_size}"
  public_agents_vm_size  = "${local.vm_size}"

  dcos_instance_os = "${local.dcos_instance_os}"

  dcos_variant = "${local.dcos_variant}"
  dcos_version = "1.13.3"

  # dcos_license_key_contents = "${file("~/license.txt")}"
  #ansible_bundled_container = "mesosphere/dcos-ansible-bundle:feature-windows-support-039d79d"
  ansible_bundled_container = "sergiimatusepam/dcos-ansible-bundle:feature-windows-support"

  # provide a SHA512 hashed password, here "deleteme"
  dcos_superuser_password_hash = "$6$rounds=656000$YSvuFmasQDXheddh$TpYlCxNHF6PbsGkjlK99Pwxg7D0mgWJ.y0hE2JKoa61wHx.1wtxTAHVRHfsJU9zzHWDoE08wpdtToHimNR9FJ/"
  dcos_superuser_username      = "demo-super"

  additional_windows_private_agent_os_user   = "${module.winagent.admin_username}"
  additional_windows_private_agent_passwords = ["${concat(module.winagent.windows_passwords)}"]
  additional_windows_private_agent_ips       = ["${concat(module.winagent.private_ips)}"]
}

module "winagent" {
  source = "dcos-terraform/windows-instance/azurerm"
  providers = {
    azurerm = "azurerm"
  }

  location         = "${local.location}"
  dcos_instance_os = "${local.dcos_winagent_os}"
  cluster_name     = "${local.cluster_name}"

  # be aware - Azure limits the Windows hostname with 15 chars:
  hostname_format = "winagt-%[1]d-%[2]s"
  image = {
    "offer"     = "MicrosoftWindowsServer"
    "publisher" = "WindowsServer"
    "sku"       = "Datacenter-Core-1809-with-Containers-smalldisk"
    "version"   = "17763.615.1907121548"
  }
  subnet_id           = "${module.dcos.infrastructure.subnet_id}"
  resource_group_name = "${module.dcos.infrastructure.resource_group_name}"
  vm_size             = "${local.vm_size}"
  admin_username      = "dcosadmin"
  public_ssh_key      = "${local.ssh_public_key_file}"

  num = "3"
}

output "winagent-ips" {
  description = "Windows IP"
  value       = "${module.winagent.public_ips}"
}

output "windows_passwords" {
  description = "Windows Password for user ${module.winagent.admin_username}"
  value       = ["${concat(module.winagent.windows_passwords)}"]
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}
