output "public_ip" {
  description = "Public IP address of the load balancer used to public agents"
  value       = "${openstack_networking_floatingip_v2.public_agents_lb_fip.address}"
}
