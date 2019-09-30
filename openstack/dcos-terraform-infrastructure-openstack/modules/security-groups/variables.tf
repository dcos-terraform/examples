variable "admin_ips" {
  description = "List of CIDR admin IPs"
  default     = "0.0.0.0/0"
}

variable "public_agents_access_ips" {
  description = "List of ips allowed access to public agents."
  default     = "0.0.0.0/0"
}

variable "cluster_name" {
  description = "Name of the DC/OS cluster"
  default     = "openstack-example"
}

variable "public_agents_additional_ports" {
  description = "List of additional ports allowed for public access on public agents (80 and 443 open by default)"
  type        = "list"
  default     = []
}

