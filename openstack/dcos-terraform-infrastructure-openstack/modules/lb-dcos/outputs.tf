output "lb_public_agents.public_ip" {
  description = "Public IP address of the load balancer used to public agents"
  value       = "${module.dcos-lb-public-agents.public_ip}"
}

output "lb_masters.public_ip" {
  description = "Public IP address of the load balancer used to public agents"
  value       = "${module.dcos-lb-masters.public_ip}"
}

output "lb_masters.private_ip" {
  description = "Private (internal) IP address of the load balancer used for masters"
  value       = "${module.dcos-lb-masters-internal.private_ip}"
}
