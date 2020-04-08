resource "openstack_lb_loadbalancer_v2" "masters_internal_lb" {
  description        = "DC/OS Master Loadbalancer (Internal)"
  vip_subnet_id      = "${var.subnet_id}"
  security_group_ids = ["${var.security_group_id}"]
}

resource "openstack_lb_listener_v2" "masters_internal_lb_listener" {
  count           = "${length(var.internal_services)}"
  protocol        = "TCP"
  protocol_port   = "${element(var.internal_services, count.index)}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.masters_internal_lb.id}"
}

resource "openstack_lb_pool_v2" "masters_internal_lb_pool" {
  count       = "${length(var.internal_services)}"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${openstack_lb_listener_v2.masters_internal_lb_listener.*.id[count.index]}"
}

resource "openstack_lb_member_v2" "masters_internal_lb_members" {
  count         = "${length(var.num_masters) * length(var.internal_services)}"
  address       = "${var.dcos_masters_ip_addresses[count.index % length(var.num_masters)]}"
  protocol_port = "${var.internal_services[(count.index / length(var.num_masters))]}"
  pool_id       = "${openstack_lb_pool_v2.masters_internal_lb_pool.*.id[(count.index / length(var.num_masters))]}"
  subnet_id     = "${var.subnet_id}"
}
