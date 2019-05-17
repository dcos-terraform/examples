output "private_ip" {
  description = "Private (internal) IP address of the load balancer used to access masters"
  value       = "${openstack_lb_loadbalancer_v2.masters_internal_lb.vip_address}"
}
