/**
 * DC/OS on OpenStack
 * ==================
 * This module creates typical DS/OS infrastructure on OpenStack.
 *
 * Known Issues
 * ------------
 *
 * No support (yet) for block storage
 * No support (yet) for configuring TLS
 * No support (yet) for multiple regions
 *
 */
locals {
  ssh_public_key_file = "${var.ssh_public_key_file == "" ? format("%s/main.tf", path.module) : var.ssh_public_key_file}"
  ssh_key_content     = "${var.ssh_public_key_file == "" ? var.ssh_public_key : file(local.ssh_public_key_file)}"
}

resource "openstack_compute_keypair_v2" "deployer" {
  name       = "${var.cluster_name}-deployer-key"
  public_key = "${local.ssh_key_content}"
}

module "dcos-security-groups" {
  source                         = "./modules/security-groups"
  public_agents_additional_ports = "${var.public_agents_additional_ports}"
}

module "dcos-network" {
  source = "./modules/network"

  cluster_name        = "${var.cluster_name}"
  external_network_id = "${var.external_network_id}"
}

module "dcos-bootstrap-instance" {
  source = "./modules/bootstrap"

  network_id                  = "${module.dcos-network.network_id}"
  cluster_name                = "${var.cluster_name}"
  floating_ip_pool            = "${var.floating_ip_pool}"
  key_pair                    = "${var.cluster_name}-deployer-key"
  associate_public_ip_address = "${var.bootstrap_associate_public_ip_address}"
  image                       = "${var.bootstrap_image}"
  user_data                   = "${var.user_data}"
  security_groups             = ["${list(module.dcos-security-groups.internal, module.dcos-security-groups.admin)}"]
  flavor_name                 = "${var.bootstrap_flavor_name}"
}

module "dcos-master-instances" {
  source = "./modules/masters"

  network_id                  = "${module.dcos-network.network_id}"
  cluster_name                = "${var.cluster_name}"
  num_masters                 = "${var.num_masters}"
  key_pair                    = "${var.cluster_name}-deployer-key"
  image                       = "${var.master_image}"
  associate_public_ip_address = "${var.masters_associate_public_ip_address}"
  floating_ip_pool            = "${var.floating_ip_pool}"
  user_data                   = "${var.user_data}"
  security_groups             = ["${list(module.dcos-security-groups.internal, module.dcos-security-groups.admin)}"]
  flavor_name                 = "${var.masters_flavor_name}"
}

module "dcos-public-agent-instances" {
  source = "./modules/public-agents"

  network_id                  = "${module.dcos-network.network_id}"
  cluster_name                = "${var.cluster_name}"
  associate_public_ip_address = "${var.public_agents_associate_public_ip_address}"
  floating_ip_pool            = "${var.floating_ip_pool}"
  num_public_agents           = "${var.num_public_agents}"
  key_pair                    = "${var.cluster_name}-deployer-key"
  image                       = "${var.public_agent_image}"
  user_data                   = "${var.user_data}"
  security_groups             = ["${list(module.dcos-security-groups.internal, module.dcos-security-groups.admin, module.dcos-security-groups.public_agents)}"]
  flavor_name                 = "${var.public_agents_flavor_name}"
}

module "dcos-private-agent-instances" {
  source = "./modules/private-agents"

  network_id                  = "${module.dcos-network.network_id}"
  cluster_name                = "${var.cluster_name}"
  num_private_agents          = "${var.num_private_agents}"
  key_pair                    = "${var.cluster_name}-deployer-key"
  image                       = "${var.private_agent_image}"
  associate_public_ip_address = "${var.private_agents_associate_public_ip_address}"
  floating_ip_pool            = "${var.floating_ip_pool}"
  user_data                   = "${var.user_data}"
  security_groups             = ["${list(module.dcos-security-groups.internal, module.dcos-security-groups.admin)}"]
  flavor_name                 = "${var.private_agents_flavor_name}"
}

module "dcos-lb" {
  source = "./modules/lb-dcos"

  num_masters                        = "${var.num_masters}"
  num_public_agents                  = "${var.num_public_agents}"
  dcos_public_agents_ip_addresses    = "${module.dcos-public-agent-instances.private_ips}"
  dcos_masters_ip_addresses          = "${module.dcos-master-instances.private_ips}"
  masters_lb_security_group_id       = "${module.dcos-security-groups.master_lb}"
  public_agents_lb_security_group_id = "${module.dcos-security-groups.public_agents}"
  public_agents_additional_ports     = "${var.public_agents_additional_ports}"
  network_id                         = "${module.dcos-network.network_id}"
  subnet_id                          = "${module.dcos-network.subnet_id}"
  floating_ip_pool                   = "${var.floating_ip_pool}"
}
