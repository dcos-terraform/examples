output "public_ip" {
  description = "Public IP address of the load balancer used to access masters"
  value       = "${openstack_networking_floatingip_v2.masters_lb_fip.address}"
}
