locals {
  services = "${concat(var.public_agents_default_ports, var.public_agents_additional_ports)}"
}

resource "openstack_lb_loadbalancer_v2" "public_agents_lb" {
  description        = "DC/OS Public Agents Loadbalancer"
  vip_subnet_id      = "${var.subnet_id}"
  security_group_ids = ["${list(var.security_group_id)}"]
}

resource "openstack_lb_listener_v2" "public_agents_lb_listener" {
  count           = "${length(local.services)}"
  protocol        = "TCP"
  protocol_port   = "${element(local.services, count.index)}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.public_agents_lb.id}"
}

resource "openstack_lb_pool_v2" "public_agents_lb_pool" {
  count       = "${length(local.services)}"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${openstack_lb_listener_v2.public_agents_lb_listener.*.id[count.index]}"
}

resource "openstack_lb_member_v2" "public_agents_lb_members" {
  count         = "${length(var.num_public_agents) * length(local.services)}"
  address       = "${var.dcos_public_agents_ip_addresses[count.index % length(var.num_public_agents)]}"
  pool_id       = "${openstack_lb_pool_v2.public_agents_lb_pool.*.id[(count.index / length(var.num_public_agents))]}"
  protocol_port = "${local.services[(count.index / length(var.num_public_agents))]}"
  subnet_id     = "${var.subnet_id}"
}

resource "openstack_networking_floatingip_v2" "public_agents_lb_fip" {
  pool    = "${var.floating_ip_pool}"
  port_id = "${openstack_lb_loadbalancer_v2.public_agents_lb.vip_port_id}"
}
