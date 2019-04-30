variable "dcos_install_mode" {
  description = "specifies which type of command to execute. Options: install or upgrade"
  default     = "install"
}

data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  region_hub     = "us-west-2"
  region_spoke_1 = "us-west-2" # Limitation by GPU node's AMI ID that only lives in us-west-2

  num_masters            = "1"
  num_private_agents     = "3"
  num_public_agents      = "1"
  num_gpu_private_agents = "1"
}

provider "aws" {
  region = "${local.region_hub}"
}

module "dcos" {
  source = "git::ssh://git@github.com/dcos-terraform/terraform-aws-dcos?ref=multi-region-testing-only"

  # version = "~> 0.1.0"
  providers = {
    aws = "aws"
  }

  dcos_instance_os = "coreos_1855.5.0"

  cluster_name        = "gpu-support-hub"
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  dcos_resolvers     = "\n   - 169.254.169.253"
  num_masters        = "${local.num_masters}"
  num_private_agents = "${local.num_private_agents}"
  num_public_agents  = "${local.num_public_agents}"
  availability_zones = ["us-west-2a", "us-west-2b"]

  #private_agents_instance_type = "m5a.4xlarge"
  private_agents_instance_type = "t3.2xlarge"
  public_agents_instance_type  = "t3.xlarge"
  dcos_version                 = "1.12.3"
  dcos_variant                 = "ee"
  dcos_license_key_contents    = "${file("./license.txt")}"

  # dcos_variant = "open"
  dcos_install_mode = "${var.dcos_install_mode}"
}

output "masters-ips-site1" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address-site1" {
  value = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer-site1" {
  value = "${module.dcos.public-agents-loadbalancer}"
}

provider "aws" {
  region = "${local.region_spoke_1}"
  alias  = "spoke-1"
}

module "spoke-1" {
  source  = "git::ssh://git@github.com/dcos-terraform/terraform-aws-remote-region?ref=multi-region-testing-only"
  version = "~> 0.1.0"

  providers = {
    aws = "aws.spoke-1"
  }

  cluster_name        = "gpu-support-spoke1"
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]
  aws_ami             = "ami-d54a2cad"

  #admin_ips           = ["0.0.0.0/0"]
  enable_bootstrap     = false
  bootstrap_private_ip = "${module.dcos.infrastructure-bootstrap.private_ip}"

  # review with SRE
  # bootstrap_prereq-id  = "${module.dcos.infrastructure-bootstrap.prereq-id}"
  # masters_prereq-id  = "${module.dcos.infrastructure-masters.prereq-id}"

  num_private_agents           = "${local.num_gpu_private_agents}"
  num_public_agents            = "0"
  private_agents_instance_type = "g3.8xlarge"
  public_agents_instance_type  = "g3.8xlarge"
  #availability_zones           = ["us-west-2a"]
  subnet_range      = "172.13.0.0/16"
  dcos_install_mode = "${var.dcos_install_mode}"
}

module "vpc-peering" {
  source  = "dcos-terraform/vpc-peering/aws"
  version = "~> 2.0.0"

  providers = {
    aws.this = "aws"
    aws.peer = "aws.spoke-1"
  }

  peer_vpc_id              = "${module.spoke-1.infrastructure.vpc_id}"
  peer_cidr_block          = "${module.spoke-1.infrastructure.vpc_cidr_block}"
  peer_main_route_table_id = "${module.spoke-1.infrastructure.vpc_main_route_table_id}"
  peer_security_group_id   = "${module.spoke-1.infrastructure.security_group_internal_id}"
  this_cidr_block          = "${module.dcos.infrastructure.vpc_cidr_block}"
  this_main_route_table_id = "${module.dcos.infrastructure.vpc_main_route_table_id}"
  this_security_group_id   = "${module.dcos.infrastructure.security_group_internal_id}"
  this_vpc_id              = "${module.dcos.infrastructure.vpc_id}"
}

output "private-agents-ips-site2" {
  value = "${module.spoke-1.private_agents-ips}"
}

output "public-agents-ips-site2" {
  value = "${module.spoke-1.public_agents-ips}"
}

output "public-agents-loadbalancer-site2" {
  value = "${module.spoke-1.public-agents-loadbalancer}"
}
