output "instances" {
  description = "Public Agent instances IDs"
  value       = ["${module.dcos-public-agent-instances.instances}"]
}

output "public_ips" {
  description = "Public Agent public IPs"
  value       = ["${module.dcos-public-agent-instances.public_ips}"]
}

output "private_ips" {
  description = "Public Agent instances private IPs"
  value       = ["${module.dcos-public-agent-instances.private_ips}"]
}
