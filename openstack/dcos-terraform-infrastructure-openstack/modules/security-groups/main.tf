locals {
  public_agents_additional_ports = "${concat(list("80","443"),var.public_agents_additional_ports)}"
}

resource "openstack_networking_secgroup_v2" "internal" {
  name        = "dcos-${var.cluster_name}-internal-firewall"
  description = "Allow all internal traffic"
}

resource "openstack_networking_secgroup_rule_v2" "internal-tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "1"
  port_range_max    = "65535"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.internal.id}"
}

resource "openstack_networking_secgroup_rule_v2" "internal-udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = "1"
  port_range_max    = "65535"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.internal.id}"
}

resource "openstack_networking_secgroup_rule_v2" "internal-icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.internal.id}"
}

resource "openstack_networking_secgroup_v2" "public_agents" {
  name        = "dcos-${var.cluster_name}-public-agents-lb-firewall"
  description = "Allow incoming traffic on Public Agents load balancer"
}

resource "openstack_networking_secgroup_rule_v2" "public_agents" {
  count             = "${length(local.public_agents_additional_ports)}"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "${element(local.public_agents_additional_ports, count.index)}"
  port_range_max    = "${element(local.public_agents_additional_ports, count.index)}"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.public_agents.id}"
}

resource "openstack_compute_secgroup_v2" "master_lb" {
  name        = "dcos-${var.cluster_name}-master-lb-firewall"
  description = "Allow incoming traffic on masters load balancer"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "${var.admin_ips}"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "${var.admin_ips}"
  }
}

resource "openstack_compute_secgroup_v2" "admin" {
  name        = "dcos-${var.cluster_name}-admin-lb-firewall"
  description = "Allow incoming traffic from a list of admin IP addresses"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${var.admin_ips}"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "${var.admin_ips}"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "${var.admin_ips}"
  }

  rule {
    from_port   = 8181
    to_port     = 8181
    ip_protocol = "tcp"
    cidr        = "${var.admin_ips}"
  }

  rule {
    from_port   = 9090
    to_port     = 9090
    ip_protocol = "tcp"
    cidr        = "${var.admin_ips}"
  }
}
