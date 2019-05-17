/**
 * OpenStack Instance
 * ==================
 * This is a module to create an DC/OS OpenStack Instance.
 */

data "openstack_compute_availability_zones_v2" "region" {}

resource "openstack_compute_instance_v2" "instance" {
  count           = "${var.num}"
  name            = "${format(var.hostname_format, count.index + 1, data.openstack_compute_availability_zones_v2.region.id, var.cluster_name)}"
  image_name      = "${var.image}"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${var.key_pair}"
  user_data       = "${var.user_data}"
  security_groups = ["${var.security_groups}"]

  network = {
    uuid = "${var.network_id}"
  }
}

resource "openstack_networking_floatingip_v2" "instance_fip" {
  count = "${var.associate_public_ip_address ? var.num : 0}"
  pool  = "${var.floating_ip_pool}"
}

resource "openstack_compute_floatingip_associate_v2" "instance_fip" {
  count       = "${var.associate_public_ip_address ? var.num : 0}"
  instance_id = "${openstack_compute_instance_v2.instance.*.id[count.index]}"
  floating_ip = "${openstack_networking_floatingip_v2.instance_fip.*.address[count.index]}"
}
