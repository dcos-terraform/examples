provider "aws" {
  region = "us-east-1"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  cluster_name = "generic-dcos-demo"
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

  num_masters        = "1"
  num_private_agents = "1"
  num_public_agents  = "1"

  dcos_instance_os        = "centos_7.6"
  bootstrap_instance_type = "m5.xlarge"

  # dcos_variant              = "ee"
  # dcos_license_key_contents = "${file("~/license.txt")}"
  dcos_variant = "open"

  dcos_version              = "1.13.0"
  ansible_bundled_container = "mesosphere/dcos-ansible-bundle:feature-windows-support-c2d8296"

  # provide a SHA512 hashed password, here "deleteme"
  dcos_superuser_password_hash = "$6$rounds=656000$YSvuFmasQDXheddh$TpYlCxNHF6PbsGkjlK99Pwxg7D0mgWJ.y0hE2JKoa61wHx.1wtxTAHVRHfsJU9zzHWDoE08wpdtToHimNR9FJ/"
  dcos_superuser_username      = "demo-super"

  additional_windows_private_agent_ips       = ["${concat(module.winagent.private_ips)}"]
  additional_windows_private_agent_passwords = ["${concat(module.winagent.windows_passwords)}"]
}

module "winagent" {
  source  = "dcos-terraform/windows-instance/aws"
  version = "~> 0.0.1"

  providers = {
    aws = "aws"
  }

  cluster_name           = "${local.cluster_name}"
  hostname_format        = "%[3]s-winagent%[1]d-%[2]s"
  aws_subnet_ids         = ["${module.dcos.infrastructure.vpc.subnet_ids}"]
  aws_security_group_ids = ["${module.dcos.infrastructure.security_groups.internal}", "${module.dcos.infrastructure.security_groups.admin}"]
  aws_key_name           = "${module.dcos.infrastructure.aws_key_name}"
  aws_instance_type      = "m5.xlarge"

  # provide the number of windows agents that should be provisioned.
  num = "1"
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}

output "windows_passwords" {
  value = "${module.winagent.windows_passwords}"
}
