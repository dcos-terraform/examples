/**
 * OpenStack DC/OS Master Instances
 * ================================
 * This module creates typical DC/OS master instances
 *
 */

module "dcos-master-instances" {
  source = "../../modules/instance"

  cluster_name                = "${var.cluster_name}"
  hostname_format             = "${var.hostname_format}"
  num                         = "${var.num_masters}"
  user_data                   = "${var.user_data}"
  image                       = "${var.image}"
  flavor_name                 = "${var.flavor_name}"
  network_id                  = "${var.network_id}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  floating_ip_pool            = "${var.floating_ip_pool}"
  security_groups             = "${var.security_groups}"
  key_pair                    = "${var.key_pair}"
}
