provider "aws" {}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  cluster_name = "windows"
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
  num_private_agents = "0"
  num_public_agents  = "1"

  dcos_variant              = "ee"
  dcos_version              = "1.13.0"
  dcos_license_key_contents = "${file("~/license.txt")}"

  ansible_bundled_container = "mesosphere/dcos-ansible-bundle:latest"

  # this should be additional_windows_agent_ips. And we need a way to specify
  # their passwords
  # additional_private_agent_ips = ["${module.windowsagent.private_ips}"]
}

module "windowsagent" {
  source  = "dcos-terraform/windows-instance/aws"
  version = "~> 0.2.0"

  cluster_name           = "${local.cluster_name}"
  hostname_format        = "%[3]s-winagent%[1]d-%[2]s"
  aws_subnet_ids         = ["${module.dcos.infrastructure.vpc.subnet_ids}"]
  aws_security_group_ids = ["${module.dcos.infrastructure.security_groups.internal}"]
  aws_key_name           = "${module.dcos.infrastructure.aws_key_name}"

  # aws_extra_volumes = [
  #   {
  #     size        = "100"
  #     type        = "gp2"
  #     iops        = "3000"
  #     device_name = "/dev/xvdi"
  #   },
  #   {
  #     size        = "1000"
  #     type        = ""          # Use AWS default.
  #     iops        = "0"         # Use AWS default.
  #     device_name = "/dev/xvdj"
  #   },
  # ]

  num = "1"
}

resource "local_file" "ansible_inventory" {
  filename = "./inventory"

  content = <<EOF
[bootstraps]
${join("\n", module.dcos.infrastructure.bootstrap.public_ip)}

[masters]
${join("\n", module.dcos.infrastructure.masters.public_ips)}

[agents_private]
${join("\n", module.dcos.infrastructure.private_agents.public_ips)}

[agents_windows]
ansible_connection=winrm
ansible_winrm_transport
${formatlist("%s ansible_password=%s", module.windowsagent.public_ips, module.windowsagent.public_ips)}

[agents_public]
${join("\n", module.dcos.infrastructure.public_agents.public_ips)}

[bootstraps:vars]
node_type=bootstrap

[masters:vars]
node_type=master
dcos_legacy_node_type_name=master

[agents_private:vars]
node_type=agent
dcos_legacy_node_type_name=slave

[agents_public:vars]
node_type=agent_public
dcos_legacy_node_type_name=slave_public

[agents:children]
agents_private
agents_public
agents_windows

[dcos:children]
bootstraps
masters
agents
agents_public
agents_windows

EOF
}

resource "local_file" "vars_file" {
  filename = "./dcos.yml"

  content = <<EOF
---
${local.ansible_additional_config}

# Core Module vars. dcos['config'] needed for some of our Roles.
dcos:
  config:
  ${indent(4, module.dcos.config)}

EOF
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}
