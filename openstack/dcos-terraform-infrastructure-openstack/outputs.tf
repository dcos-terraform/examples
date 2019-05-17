output "bootstrap.instance" {
  description = "Bootstrap instance ID"
  value       = "${module.dcos-bootstrap-instance.instance}"
}

output "bootstrap.public_ip" {
  description = "Public IP of the bootstrap instance"
  value       = "${module.dcos-bootstrap-instance.public_ip}"
}

output "bootstrap.private_ip" {
  description = "Private IP of the bootstrap instance"
  value       = "${module.dcos-bootstrap-instance.private_ip}"
}

output "masters.instances" {
  description = "Master instances IDs"
  value       = ["${module.dcos-master-instances.instances}"]
}

output "masters.public_ips" {
  description = "Master instances public IPs"
  value       = ["${module.dcos-master-instances.public_ips}"]
}

output "masters.private_ips" {
  description = "Master instances private IPs"
  value       = ["${module.dcos-master-instances.private_ips}"]
}

output "private_agents.public_ips" {
  description = "Private agents public IP addresses"
  value       = ["${module.dcos-private-agent-instances.public_ips}"]
}

output "private_agents.private_ips" {
  description = "Private agents public IP addresses"
  value       = ["${module.dcos-private-agent-instances.private_ips}"]
}

output "public_agents.public_ips" {
  description = "Public agents public IP addresses"
  value       = ["${module.dcos-public-agent-instances.public_ips}"]
}

output "public_agents.private_ips" {
  description = "Public agents public IP addresses"
  value       = ["${module.dcos-public-agent-instances.private_ips}"]
}

output "lb.public_agents" {
  description = "Public agents loadbalancer external IP address"
  value       = "${module.dcos-lb.lb_public_agents.public_ip}"
}

output "lb.masters" {
  description = "Public IP address of masters loadbalancer"
  value       = "${module.dcos-lb.lb_masters.public_ip}"
}

output "lb.masters.private_ip" {
  description = "Public IP address of masters loadbalancer"
  value       = "${module.dcos-lb.lb_masters.private_ip}"
}
