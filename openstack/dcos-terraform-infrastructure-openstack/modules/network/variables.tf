variable "cluster_name" {
  description = "Name of the DC/OS cluster"
}

variable "tags" {
  description = "Add custom tags to all resources"
  type        = "map"
  default     = {}
}

variable "subnet_range" {
  description = "Private IP space to be used in CIDR format"
  default     = "172.31.0.0/16"
}

variable "external_network_id" {
  description = "The ID of the external network providing ingress / egress"
  default     = ""
}
