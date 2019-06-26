locals {
  cluster_name="development"
  num_masters                  = "1"
  num_private_agents           = "1"
  num_public_agents            = "1"
  num_winagent                 = "2"
  dcos_version                 = "1.13.0"
  dcos_instance_os             = "centos_7.5"
  bootstrap_instance_type      = "r5.large"
  masters_instance_type        = "r5.xlarge"
  private_agents_instance_type = "r5.large"
  public_agents_instance_type  = "r5.large"
  ssh_public_key_file          = "~/.ssh/id_rsa.pub"
  ssh_private_key_file         = "~/.ssh/id_rsa"
  admin_ips                    = ["${data.http.whatismyip.body}/32"]
  owner                        = "John Dow"
  expiration                   = "20h"
}

provider "aws" {
  # Change your default region here
  region = "us-west-2"
}
module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.2.0"

  cluster_name        = "${local.cluster_name}"
  ssh_public_key_file = "${local.ssh_public_key_file}"
  admin_ips           = "${local.admin_ips}"
  num_masters        = "${local.num_masters}"
  num_private_agents = "${local.num_private_agents}"
  num_public_agents  = "${local.num_public_agents}"

  dcos_version = "${local.dcos_version}"

  dcos_instance_os    = "${local.dcos_instance_os}"
  bootstrap_instance_type = "${local.bootstrap_instance_type}"
  masters_instance_type  = "${local.masters_instance_type}"
  private_agents_instance_type = "${local.private_agents_instance_type}"
  public_agents_instance_type = "${local.public_agents_instance_type}"

  providers = {
    aws = "aws"
  }
  tags = {
    owner = "${local.owner}"
    expiration = "${local.expiration}"
  }
  # Enterprise users uncomment this section and comment out below
  # dcos_variant              = "ee"
  # dcos_license_key_contents = "${file("./license.txt")}"
  # Make sure to set your credentials if you do not want the default EE
  # dcos_superuser_username          = "superuser-name"
  # dcos_superuser_password_hash = "${file("./dcos_superuser_password_hash.sha512")}"

  # Default is DC/OS
  dcos_variant = "open"
}

module "windows-agent" {
  source = "git::https://github.com/alekspv/terraform-aws-windows-instance.git?ref=support/0.2.x"
  num_winagent = "${local.num_winagent}"
  admin_ips = "${local.admin_ips}"
  vpc_id = "${module.dcos.infrastructure.vpc.id}"
  subnet_id = "${module.dcos.infrastructure.vpc.subnet_ids}"
  cluster_name = "${local.cluster_name}"
  expiration = "${local.expiration}"
  owner = "${local.owner}"
  aws_key_name = "${module.dcos.infrastructure.aws_key_name}"
  security_group_admin = "${module.dcos.infrastructure.security_groups.admin}"
  security_group_internal = "${module.dcos.infrastructure.security_groups.internal}"
  bootstrap_private_ip = "${module.dcos.infrastructure.bootstrap.private_ip}"
  bootstrap_public_ip = "${module.dcos.infrastructure.bootstrap.public_ip}"
  bootstrap_os_user = "${module.dcos.infrastructure.bootstrap.os_user}"
  ssh_private_key_file = "${local.ssh_private_key_file}"
  masters_private_ips = "${module.dcos.infrastructure.masters.private_ips}"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

output "masters-ips" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}
