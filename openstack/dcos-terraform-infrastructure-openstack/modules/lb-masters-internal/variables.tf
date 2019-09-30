variable "security_group_id" {
  description = "The security groups (firewall rules) that will be applied to this loadbalancer"
  type        = "list"
  default     = [""]
}

variable "num_masters" {
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

variable "dcos_masters_ip_addresses" {
  type    = "list"
  default = [""]
}

variable "internal_services" {
  type    = "list"
  default = ["80", "443", "2181", "5050", "8080", "8181"]
}
