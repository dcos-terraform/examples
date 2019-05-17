output "network_id" {
  description = "UUID of the network"
  value       = "${openstack_networking_network_v2.dcos_network.id}"
}

output "subnet_id" {
  description = "UUID of the subnet"
  value       = "${openstack_networking_subnet_v2.dcos_subnet.id}"
}
