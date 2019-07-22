provider "google" {
  version = "~> 2.0"
  region  = "us-west1"
  alias   = "master"
}

provider "google" {
  version = "~> 2.0"
  region  = "us-east1"
  alias   = "us-east1"
}

provider "google" {
  version = "~> 2.0"
  region  = "us-east4"
  alias   = "us-east4"
}

data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

// lets define variables which are shared between all regions
locals {
  ssh_public_key_file       = "~/.ssh/id_rsa.pub"
  cluster_name              = "rtest-dcos-ee-demo"
  dcos_license_key_contents = "${file("~/license.txt")}"
  dcos_instance_os          = "centos_7"
  dcos_variant              = "ee"
  dcos_version              = "1.13.2"

  region_networks = {
    // dont use 172.17/26 as its used by docker.
    "master"   = "172.16.0.0/16" // this is the default
    "us-west1" = "10.65.0.0/16"  // default agent network
    "us-east1" = "10.128.0.0/16"
    "us-east4" = "10.129.0.0/16"
  }

  allowed_internal_networks = ["${values(local.region_networks)}"]
}

############################################################
# main region holding masters
############################################################
module "dcos" {
  source  = "dcos-terraform/dcos/gcp"
  version = "~> 0.2.0"

  providers = {
    google = "google.master"
  }

  subnet_range       = "${local.region_networks["master"]}"
  num_masters        = 1
  num_private_agents = 1
  num_public_agents  = 1

  cluster_name        = "${local.cluster_name}"
  ssh_public_key_file = "${local.ssh_public_key_file}"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  dcos_instance_os       = "${local.dcos_instance_os}"
  bootstrap_machine_type = "n1-standard-4"

  // accepted_internal_networks is holding a list of internal use networks.
  accepted_internal_networks = "${local.allowed_internal_networks}"

  dcos_variant              = "${local.dcos_variant}"
  dcos_version              = "${local.dcos_version}"
  dcos_license_key_contents = "${local.dcos_license_key_contents}"

  # provide a SHA512 hashed password, here "deleteme"
  dcos_superuser_password_hash = "$6$rounds=656000$YSvuFmasQDXheddh$TpYlCxNHF6PbsGkjlK99Pwxg7D0mgWJ.y0hE2JKoa61wHx.1wtxTAHVRHfsJU9zzHWDoE08wpdtToHimNR9FJ/"
  dcos_superuser_username      = "demo-super"

  ansible_additional_config = <<EOF
foo: bar
bar: baz
EOF

  # add additional agents to install run
  additional_private_agent_ips = ["${concat(module.dcos-use1.private_agents.private_ips, module.dcos-use4.private_agents.private_ips)}"]
}

############################################################
# us-east1 region having agents
############################################################
module "dcos-use1" {
  source  = "dcos-terraform/infrastructure/gcp"
  version = "~> 0.2.0"

  providers = {
    google = "google.us-east1"
  }

  admin_ips   = ["${data.http.whatismyip.body}/32"]
  name_prefix = "use1"

  cluster_name = "${local.cluster_name}"

  num_bootstrap      = 0
  num_masters        = 0
  num_private_agents = 1
  num_public_agents  = 0

  forwarding_rule_disable_masters       = true
  forwarding_rule_disable_public_agents = true

  // accepted_internal_networks is holding a list of internal use networks.
  accepted_internal_networks = "${local.allowed_internal_networks}"

  infra_dcos_instance_os    = "${local.dcos_instance_os}"
  infra_public_ssh_key_path = "${local.ssh_public_key_file}"
  agent_cidr_range          = "${local.region_networks["us-east1"]}"
}

module "network-connection-master-use1" {
  source  = "dcos-terraform/network-peering/gcp"
  version = "~> 0.2.0"

  providers = {
    google.local  = "google.master"
    google.remote = "google.us-east1"
  }

  cluster_name             = "${local.cluster_name}"
  local_network_name       = "master"
  local_network_self_link  = "${module.dcos.infrastructure.network_self_link}"
  remote_network_name      = "use1"
  remote_network_self_link = "${module.dcos-use1.network_self_link}"
}

############################################################
# us-east4 region having agents
############################################################
module "dcos-use4" {
  source  = "dcos-terraform/infrastructure/gcp"
  version = "~> 0.2.0"

  providers = {
    google = "google.us-east4"
  }

  admin_ips   = ["${data.http.whatismyip.body}/32"]
  name_prefix = "use4"

  cluster_name = "${local.cluster_name}"

  num_bootstrap      = 0
  num_masters        = 0
  num_private_agents = 1
  num_public_agents  = 0

  forwarding_rule_disable_masters       = true
  forwarding_rule_disable_public_agents = true

  // accepted_internal_networks is holding a list of internal use networks.
  accepted_internal_networks = "${local.allowed_internal_networks}"

  infra_dcos_instance_os    = "${local.dcos_instance_os}"
  infra_public_ssh_key_path = "${local.ssh_public_key_file}"
  agent_cidr_range          = "${local.region_networks["us-east4"]}"
}

module "network-connection-master-use4" {
  source  = "dcos-terraform/network-peering/gcp"
  version = "~> 0.2.0"

  providers = {
    google.local  = "google.master"
    google.remote = "google.us-east4"
  }

  cluster_name             = "${local.cluster_name}"
  local_network_name       = "master"
  local_network_self_link  = "${module.dcos.infrastructure.network_self_link}"
  remote_network_name      = "use4"
  remote_network_self_link = "${module.dcos-use4.network_self_link}"
  wait_for_peering_id      = "${module.network-connection-master-use1.peering_resource_id}"
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}
