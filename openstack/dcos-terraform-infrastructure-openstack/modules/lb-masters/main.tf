locals {
  services = ["80", "443"]
}

resource "openstack_lb_loadbalancer_v2" "masters_lb" {
  description        = "DC/OS Masters Loadbalancer"
  vip_subnet_id      = "${var.subnet_id}"
  security_group_ids = ["${var.security_group_id}"]
}

resource "openstack_lb_listener_v2" "masters_lb_listener" {
  count           = "${length(local.services)}"
  protocol        = "TCP"
  protocol_port   = "${element(local.services, count.index)}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.masters_lb.id}"
}

resource "openstack_lb_pool_v2" "masters_lb_pool" {
  count       = "${length(local.services)}"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${openstack_lb_listener_v2.masters_lb_listener.*.id[count.index]}"
}

resource "openstack_lb_member_v2" "masters_lb_members" {
  count         = "${length(var.num_masters) * length(local.services)}"
  address       = "${var.dcos_masters_ip_addresses[count.index % length(var.num_masters)]}"
  protocol_port = "${local.services[(count.index / length(var.num_masters))]}"
  pool_id       = "${openstack_lb_pool_v2.masters_lb_pool.*.id[(count.index / length(var.num_masters))]}"
  subnet_id     = "${var.subnet_id}"
}

resource "openstack_networking_floatingip_v2" "masters_lb_fip" {
  pool    = "${var.floating_ip_pool}"
  port_id = "${openstack_lb_loadbalancer_v2.masters_lb.vip_port_id}"
}
