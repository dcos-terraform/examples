variable "cluster_name" {
  description = "Name of the DC/OS cluster"
  default     = "dcos-example"
}

variable "num_masters" {
  description = "Specify the amount of masters. For redundancy you should have at least 3"
  default     = "3"
}

variable "num_private_agents" {
  description = "Specify the amount of private agents. These agents will provide your main resources"
  default     = "2"
}

variable "num_public_agents" {
  description = "Specify the amount of public agents. These agents will host marathon-lb and edgelb"
  default     = "1"
}

variable "floating_ip_pool" {
  description = "The name of the pool of addresses from which floating IPs can be allocated"
}

variable "ssh_public_key_file" {
  description = "Path to SSH public key. This is mandatory but can be set to an empty string if you want to use ssh_public_key with the key as string."
}

variable "external_network_id" {
  description = "The UUID of the external network"
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

variable "bootstrap_os_user" {
  description = "Default OS user for bootstrap node"
}

variable "masters_os_user" {
  description = "Default OS user for masters"
}

variable "private_agents_os_user" {
  description = "Default OS user for private agents"
}

variable "public_agents_os_user" {
  description = "Default OS user for public agents"
}

variable "bootstrap_associate_public_ip_address" {
  description = "[BOOTSTRAP] Associate a public ip address with these instances"
  default     = true
}

variable "masters_associate_public_ip_address" {
  description = "[MASTERS] Associate a public ip address with these instances"
  default     = false
}

variable "private_agents_associate_public_ip_address" {
  description = "[PRIVATE AGENTS] Associate a public ip address with these instances"
  default     = false
}

variable "public_agents_associate_public_ip_address" {
  description = "[PUBLIC AGENTS] Associate a public ip address with these instances"
  default     = false
}

variable "dcos_exhibitor_storage_backend" {
  default     = "static"
  description = "options are static, aws_s3, azure, or zookeeper (recommended)"
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

variable "user_data" {
  description = "user-data (cloud-init) contents to pass to instances"
  default     = ""
}
