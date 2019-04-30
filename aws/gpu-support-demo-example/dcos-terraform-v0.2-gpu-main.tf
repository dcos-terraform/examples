provider "aws" {
  # Change your default region here
  region = "us-east-1"
  alias  = "master"
}

provider "aws" {
  # GPU Region Limited by AMI_ID
  region = "us-west-2"
  alias  = "usw2"
}

resource "random_id" "cluster_name" {
  prefix      = "gpu-demo-"
  byte_length = 2
}

# lets define variables which are shared between all regions
locals {
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  cluster_name        = "${random_id.cluster_name.hex}"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  region_networks = {
    # dont use 172.17/26 as its used by docker.
    "master" = "172.16.0.0/16" // this is the default
    "usw2"   = "10.128.0.0/16" // GPU Agents Region
  }

  num_masters              = "1"
  num_local_private_agents = "3"
  num_local_public_agents  = "1"
  num_gpu_private_agents   = "1"

  // us-east-1e does not have m5 instances
  us_east_1_availability_zones = ["us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1f",
  ]

  // us-west-2 only has 4 Availabilitiy Zones (a-d)
  us_west_2_availability_zones = ["us-west-2a",
    "us-west-2b",
    "us-west-2c",
  ]
}

module "dcos" {
  source                       = "dcos-terraform/dcos/aws"
  version                      = "~> 0.2.0"
  cluster_name                 = "${local.cluster_name}"
  ssh_public_key_file          = "${local.ssh_public_key_file}"
  admin_ips                    = ["${local.admin_ips}"]
  subnet_range                 = "${local.region_networks["master"]}"
  num_masters                  = "${local.num_masters}"
  num_private_agents           = "${local.num_local_private_agents}"
  num_public_agents            = "${local.num_local_public_agents}"
  dcos_instance_os             = "centos_7.5"
  bootstrap_instance_type      = "m5.large"
  masters_instance_type        = "m5.xlarge"
  private_agents_instance_type = "m5.xlarge"
  public_agents_instance_type  = "m5.xlarge"
  accepted_internal_networks   = "${values(local.region_networks)}"
  additional_private_agent_ips = ["${module.dcos-usw2.private_agents.private_ips}"]

  // us-east-1e does not have m5 instances
  availability_zones = ["${local.us_east_1_availability_zones}"]

  dcos_version  = "1.12.3"
  dcos_security = "strict"

  private_agents_extra_volumes = [
    {
      size        = "100"
      type        = "gp2"
      device_name = "/dev/xvdi"
    },
  ]

  providers = {
    aws = "aws.master"
  }

  dcos_variant              = "ee"
  dcos_license_key_contents = "${file("./license.txt")}"

  dcos_master_discovery          = "master_http_loadbalancer"
  dcos_exhibitor_storage_backend = "aws_s3"
  dcos_exhibitor_explicit_keys   = "false"
  with_replaceable_masters       = "true"
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

module "dcos-usw2" {
  source                       = "dcos-terraform/infrastructure/aws"
  version                      = "~> 0.2.0"
  admin_ips                    = ["${local.admin_ips}"]
  name_prefix                  = "usw2"
  aws_ami                      = "ami-d54a2cad"
  cluster_name                 = "${local.cluster_name}"
  accepted_internal_networks   = "${values(local.region_networks)}"
  num_masters                  = 0
  num_private_agents           = "${local.num_gpu_private_agents}"
  num_public_agents            = 0
  private_agents_instance_type = "g3.8xlarge"
  public_agents_instance_type  = "g3.8xlarge"
  lb_disable_public_agents     = true
  lb_disable_masters           = true
  ssh_public_key_file          = "${local.ssh_public_key_file}"
  subnet_range                 = "${local.region_networks["usw2"]}"
  availability_zones           = ["${local.us_west_2_availability_zones}"]

  providers = {
    aws = "aws.usw2"
  }
}

module "vpc-connection-master-usw2" {
  source  = "dcos-terraform/vpc-peering/aws" // module init the peering
  version = "~> 1.0.0"

  providers = {
    "aws.local"  = "aws.master"
    "aws.remote" = "aws.usw2"
  }

  local_vpc_id        = "${module.dcos.infrastructure.vpc.id}"
  local_subnet_range  = "${local.region_networks["master"]}"
  remote_vpc_id       = "${module.dcos-usw2.vpc.id}"
  remote_subnet_range = "${local.region_networks["usw2"]}"
}
