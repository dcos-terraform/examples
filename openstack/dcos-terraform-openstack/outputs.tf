output "masters-ips" {
  description = "Master IP addresses"
  value       = "${coalescelist(module.dcos-infrastructure.masters.public_ips, module.dcos-infrastructure.masters.private_ips)}"
}

output "masters-loadbalancer" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos-infrastructure.lb.masters}"
}

output "masters-internal-loadbalancer" {
  description = "This is the internal load balancer address to access the DC/OS Services"
  value       = "${module.dcos-infrastructure.lb.masters.private_ip}"
}

output "public-agents-loadbalancer" {
  description = "This is the load balancer address to access the DC/OS public agents"
  value       = "${module.dcos-infrastructure.lb.public_agents}"
}
