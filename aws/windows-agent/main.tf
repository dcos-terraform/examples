provider "aws" {}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  cluster_name = "generic-dcos-ee-demo"
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

  dcos_instance_os        = "centos_7.5"
  bootstrap_instance_type = "m4.xlarge"

  dcos_variant              = "ee"
  dcos_version              = "1.13.1"
  dcos_license_key_contents = "${file("~/license.txt")}"

  # provide a SHA512 hashed password, here "deleteme"
  dcos_superuser_password_hash = "$6$rounds=656000$YSvuFmasQDXheddh$TpYlCxNHF6PbsGkjlK99Pwxg7D0mgWJ.y0hE2JKoa61wHx.1wtxTAHVRHfsJU9zzHWDoE08wpdtToHimNR9FJ/"
  dcos_superuser_username      = "demo-super"
}

module "windowsagent" {
  source  = "dcos-terraform/windows-instance/aws"
  version = "~> 0.2.0"

  cluster_name           = "${local.cluster_name}"
  hostname_format        = "%[3]s-winagent%[1]d-%[2]s"
  aws_subnet_ids         = ["${module.dcos.infrastructure.vpc.subnet_ids}"]
  aws_security_group_ids = ["${module.dcos.infrastructure.security_groups.internal}", "${module.dcos.infrastructure.security_groups.admin}"]
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
${module.dcos.infrastructure.bootstrap.public_ip}
[masters]
${join("\n", module.dcos.infrastructure.masters.public_ips)}
[agents_private]
${join("\n", module.dcos.infrastructure.private_agents.public_ips)}
[agents_public]
${join("\n", module.dcos.infrastructure.public_agents.public_ips)}
[agents_windows]
${join("\n",formatlist("%s ansible_user=${module.windowsagent.os_user} ansible_password=%s", module.windowsagent.public_ips, module.windowsagent.windows-passwords))}
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
[agents_windows:vars]
ansible_connection=winrm
ansible_winrm_transport=basic
ansible_winrm_server_cert_validation=ignore
[agents:children]
agents_private
agents_public
agents_windows
[dcos:children]
bootstraps
masters
agents
agents_public
EOF
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}

output "passwords" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.windowsagent.windows-passwords}"
}
