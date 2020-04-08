variable "security_group_id" {
  description = "The security group (firewall rules) that will be applied to this loadbalancer"
  type        = "string"
  default     = ""
}

variable "num_public_agents" {
  default = ""
}

variable "network_id" {
  description = "The network ID in which the loadbalancer should sit"
  default     = ""
}

variable "subnet_id" {
  description = "The subnet ID in which lb members should reside"
  default     = ""
}

variable "floating_ip_pool" {
  description = "The pool from which floating IP addresses should be allocated"
  default     = ""
}

variable "dcos_public_agents_ip_addresses" {
  type    = "list"
  default = [""]
}

variable "public_agents_default_ports" {
  type    = "list"
  default = ["80", "443"]
}

variable "public_agents_additional_ports" {
  description = "List of additional ports allowed for public access on public agents"
  default     = []
}
