/**
 * DC/OS OpenStack Network
 * =======================
 * This module creates the network infrastructure necessary for DC/OS
 * on OpenStack
 */

resource "openstack_networking_network_v2" "dcos_network" {
  name = "dcos_network"
}

resource "openstack_networking_subnet_v2" "dcos_subnet" {
  name       = "dcos_subnet"
  network_id = "${openstack_networking_network_v2.dcos_network.id}"
  cidr       = "${var.subnet_range}"
  ip_version = 4
}

resource "openstack_networking_router_v2" "dcos_router" {
  name                = "dcos_router"
  admin_state_up      = true
  external_network_id = "${var.external_network_id}"
}

resource "openstack_networking_router_interface_v2" "dcos_router_int" {
  router_id = "${openstack_networking_router_v2.dcos_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.dcos_subnet.id}"
}
