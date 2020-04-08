output "instances" {
  description = "List of instance IDs"
  value       = ["${openstack_compute_instance_v2.instance.*.id}"]
}

output "private_ips" {
  description = "List of private IP addresses created by this module"
  value       = ["${openstack_compute_instance_v2.instance.*.network.0.fixed_ip_v4}"]
}

output "public_ips" {
  description = "List of public ip addresses created by this module"
  value       = ["${openstack_networking_floatingip_v2.instance_fip.*.address}"]
}
