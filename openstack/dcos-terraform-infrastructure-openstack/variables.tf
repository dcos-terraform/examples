variable "ssh_key_pair" {
  type    = "string"
  default = "deadline"
}

variable "num_masters" {
  type    = "string"
  default = ""
}

variable "num_public_agents" {
  type    = "string"
  default = ""
}

variable "num_private_agents" {
  type    = "string"
  default = ""
}

variable "internal_services" {
  type    = "list"
  default = ["80", "443", "2181", "5050", "8080", "8181"]
}

variable "dcos_instance_os" {
  description = "Operating system to use."
  default     = "CentOS 7.6-docker"
}

variable "subnet_range" {
  description = "Private IP space to be used in CIDR format"
  default     = "172.16.0.0/16"
}

variable "cluster_name" {
  description = "Name of the DC/OS cluster"
}

variable "external_network_id" {
  description = "The UUID of the external network"
}

variable "floating_ip_pool" {
  description = "The name of the pool of addresses from which floating IPs can be allocated"
}

variable "ssh_public_key" {
  description = "SSH public key in authorized keys format (e.g. 'ssh-rsa ..') to be used with the instances. Make sure you added this key to your ssh-agent."

  default = ""
}

variable "ssh_public_key_file" {
  description = "Path to SSH public key. This is mandatory but can be set to an empty string if you want to use ssh_public_key with the key as string."
}

variable "bootstrap_image" {
  description = "OS image to be used for bootstrap node"
}

variable "public_agent_image" {
  description = "OS image to be used for public agent nodes"
}

variable "private_agent_image" {
  description = "OS image to be used for private agent nodes"
}

variable "master_image" {
  description = "OS image to be used for master nodes"
}

variable "bootstrap_associate_public_ip_address" {
  description = "Associate a public ip address with boostrap instances"
  default     = true
}

variable "masters_associate_public_ip_address" {
  description = "Associate a public ip address with master instances"
  default     = false
}

variable "private_agents_associate_public_ip_address" {
  description = "Associate a public ip address with private agent instances"
  default     = false
}

variable "public_agents_associate_public_ip_address" {
  description = "Associate a public ip address with public agent instances"
  default     = true
}

variable "user_data" {
  description = "User data to be used on this instance (cloud-init)"
  default     = ""
}

variable "bootstrap_flavor_name" {
  description = "The name of the flavor used for the bootstrap instance"
  default     = ""
}

variable "masters_flavor_name" {
  description = "The name of the flavor used for the bootstrap instance"
  default     = ""
}

variable "public_agents_flavor_name" {
  description = "The name of the flavor used for the bootstrap instance"
  default     = ""
}

variable "private_agents_flavor_name" {
  description = "The name of the flavor used for the bootstrap instance"
  default     = ""
}

variable "public_agents_additional_ports" {
  description = "List of additional ports allowed for public access on public agents"
  default     = []
}
