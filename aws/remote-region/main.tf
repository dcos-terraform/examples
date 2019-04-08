provider "aws" {
  region = "us-east-1"
  alias  = "master"
}

provider "aws" {
  region = "us-west-2"
  alias  = "us-west-2"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu-west-1"
}

data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

// lets define variables which are shared between all regions
locals {
  ssh_public_key_file       = "~/.ssh/id_rsa.pub"
  cluster_name              = "remotetest"
  dcos_license_key_contents = "${file("~/license.txt")}"
  dcos_variant              = "ee"
  dcos_version              = "1.12.3"

  region_networks = {
    // dont use 172.17/26 as its used by docker.
    "master"    = "172.16.0.0/16" // this is the default
    "us-west-2" = "10.128.0.0/16"
    "eu-west-1" = "10.129.0.0/16"
  }

  allowed_internal_networks = ["${values(local.region_networks)}"]
}

############################################################
# main region holding masters
############################################################
module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws.master"
  }

  subnet_range       = "${local.region_networks["master"]}"
  num_masters        = 1
  num_private_agents = 1
  num_public_agents  = 1

  dcos_instance_os           = "centos_7.5"
  bootstrap_instance_type    = "m4.xlarge"
  bootstrap_root_volume_type = "gp2"

  // accepted_internal_networks is holding a list of internal use networks.
  // They will be
  accepted_internal_networks = "${local.allowed_internal_networks}"

  cluster_name              = "${local.cluster_name}"
  ssh_public_key_file       = "${local.ssh_public_key_file}"
  admin_ips                 = ["${data.http.whatismyip.body}/32"]
  dcos_license_key_contents = "${local.dcos_license_key_contents}"
  dcos_variant              = "${local.dcos_variant}"
  dcos_version              = "${local.dcos_version}"

  #ansible related config
  ansible_bundled_container = "fatz/dcos-ansible-bundle:additional-vars"

  ansible_additional_config = <<EOF
foo: bar
bar: baz
EOF

  # add additional agents to install run
  additional_private_agent_ips = ["${concat(module.dcos-usw2.private_agents.private_ips,module.dcos-euw1.private_agents.private_ips)}"]
}

############################################################
# us-west-2 region having agents
############################################################
module "dcos-usw2" {
  source  = "dcos-terraform/infrastructure/aws"
  version = "~> 0.2.0"

  admin_ips   = ["${data.http.whatismyip.body}/32"]
  name_prefix = "usw2"

  cluster_name               = "${local.cluster_name}"
  accepted_internal_networks = "${local.allowed_internal_networks}"

  num_masters        = 0
  num_private_agents = 1
  num_public_agents  = 0

  lb_disable_public_agents = true
  lb_disable_masters       = true

  ssh_public_key_file = "${local.ssh_public_key_file}"
  subnet_range        = "${local.region_networks["us-west-2"]}"

  providers = {
    aws = "aws.us-west-2"
  }
}

# connect to master region
module "vpc-connection-master-usw2" {
  source  = "dcos-terraform/vpc-peering/aws" // module init the peering
  version = "~> 0.2.0"

  providers = {
    "aws.local"  = "aws.master"
    "aws.remote" = "aws.us-west-2"
  }

  local_vpc_id        = "${module.dcos.infrastructure.vpc_id}"
  local_subnet_range  = "${local.region_networks["master"]}"
  remote_vpc_id       = "${module.dcos-usw2.vpc.id}"
  remote_subnet_range = "${local.region_networks["us-west-2"]}"
}

############################################################
# eu-west-1 region having agents
############################################################
module "dcos-euw1" {
  source  = "dcos-terraform/infrastructure/aws"
  version = "~> 0.2.0"

  admin_ips   = ["${data.http.whatismyip.body}/32"]
  name_prefix = "euw1"

  cluster_name               = "${local.cluster_name}"
  accepted_internal_networks = "${local.allowed_internal_networks}"

  num_masters        = 0
  num_private_agents = 1
  num_public_agents  = 0

  lb_disable_public_agents = true
  lb_disable_masters       = true

  ssh_public_key_file = "${local.ssh_public_key_file}"
  subnet_range        = "${local.region_networks["eu-west-1"]}"

  providers = {
    aws = "aws.eu-west-1"
  }
}

# connect to master region
module "vpc-connection-master-euw1" {
  source  = "dcos-terraform/vpc-peering/aws" // module init the peering
  version = "~> 0.2.0"

  providers = {
    "aws.local"  = "aws.master"
    "aws.remote" = "aws.eu-west-1"
  }

  local_vpc_id        = "${module.dcos.infrastructure.vpc_id}"
  local_subnet_range  = "${local.region_networks["master"]}"
  remote_vpc_id       = "${module.dcos-euw1.vpc.id}"
  remote_subnet_range = "${local.region_networks["eu-west-1"]}"
}

output "elb.masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}
