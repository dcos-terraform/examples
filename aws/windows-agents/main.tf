provider "aws" {}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  cluster_name = "dcoswin"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws"
  }

  cluster_name        = "${local.cluster_name}"
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = 1
  num_private_agents = 1
  num_public_agents  = 1

  dcos_variant = "ee"
  dcos_version = "2.1.0-beta2"

  #### WIP: DELETEME

  ansible_bundled_container         = "fatz/dcos-ansible-bundle:merge-agentroles"
  custom_dcos_download_path         = "https://downloads.mesosphere.com/dcos-enterprise/testing/pull/7548/dcos_generate_config.ee.sh"
  custom_dcos_windows_download_path = "https://downloads.mesosphere.com/dcos-enterprise/testing/pull/7548/windows/dcos_generate_config_win.ee.sh"

  #### WIP: DELETEME

  dcos_license_key_contents = "${file("~/license.txt")}"
  # provide a SHA512 hashed password, here "deleteme"
  dcos_superuser_password_hash               = "$6$rounds=656000$YSvuFmasQDXheddh$TpYlCxNHF6PbsGkjlK99Pwxg7D0mgWJ.y0hE2JKoa61wHx.1wtxTAHVRHfsJU9zzHWDoE08wpdtToHimNR9FJ/"
  dcos_superuser_username                    = "demo-super"
  dcos_enable_windows_agents                 = "true"
  additional_windows_private_agent_ips       = ["${concat(module.windowsagent.private_ips)}"]
  additional_windows_private_agent_passwords = ["${concat(module.windowsagent.windows_passwords)}"]
}

module "windowsagent" {
  source  = "dcos-terraform/windows-instance/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws"
  }

  cluster_name    = "${local.cluster_name}"
  hostname_format = "%[3]s-winagent%[1]d-%[2]s"

  aws_subnet_ids         = ["${module.dcos.infrastructure.vpc.subnet_ids}"]
  aws_security_group_ids = ["${module.dcos.infrastructure.security_groups.internal}", "${module.dcos.infrastructure.security_groups.admin}"]
  aws_key_name           = "${module.dcos.infrastructure.aws_key_name}"

  # provide the number of windows agents that should be provisioned.
  num = 1
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}
