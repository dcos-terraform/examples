/**
 * OpenStack LB DC/OS
 * ==================
 * This module creates three load balancers for DC/OS.
 *
 * External masters application load balancer
 * ------------------------------------------
 * This load balancer keeps an redundant entry point to the masters
 *
 * Internal masters network load balancer
 * --------------------------------------
 * this load balancer is used for internal communication to masters
 *
 * External public agents network load balancer
 * --------------------------------------------
 * This load balancer keeps a single entry point to your public agents no matter how many you're running.
 */

module "dcos-lb-masters" {
  source = "../lb-masters"

  dcos_masters_ip_addresses = "${var.dcos_masters_ip_addresses}"
  network_id                = "${var.network_id}"
  subnet_id                 = "${var.subnet_id}"
  security_group_id         = ["${var.masters_lb_security_group_id}"]
  num_masters               = "${var.num_masters}"
  floating_ip_pool          = "${var.floating_ip_pool}"
}

module "dcos-lb-masters-internal" {
  source = "../lb-masters-internal"

  dcos_masters_ip_addresses = "${var.dcos_masters_ip_addresses}"
  network_id                = "${var.network_id}"
  subnet_id                 = "${var.subnet_id}"
  security_group_id         = "${var.masters_lb_security_group_id}"
  num_masters               = "${var.num_masters}"
}

module "dcos-lb-public-agents" {
  source = "../lb-public-agents"

  dcos_public_agents_ip_addresses = "${var.dcos_public_agents_ip_addresses}"
  network_id                      = "${var.network_id}"
  subnet_id                       = "${var.subnet_id}"
  security_group_id               = "${var.public_agents_lb_security_group_id}"
  num_public_agents               = "${var.num_public_agents}"
  public_agents_additional_ports  = ["${var.public_agents_additional_ports}"]
  floating_ip_pool                = "${var.floating_ip_pool}"
}
