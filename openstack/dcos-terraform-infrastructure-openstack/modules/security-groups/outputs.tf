output "master_lb" {
  description = "UUID of security group for masters load balacer"
  value       = "${openstack_compute_secgroup_v2.master_lb.*.id}"
}

output "public_agents" {
  description = "UUID of security group for public agents load balancer"
  value       = "${openstack_networking_secgroup_v2.public_agents.id}"
}

output "admin" {
  description = "UUID of security group for admin access"
  value       = "${openstack_compute_secgroup_v2.admin.id}"
}

output "internal" {
  description = "UUID of security group for internal access"
  value       = "${openstack_networking_secgroup_v2.internal.id}"
}
