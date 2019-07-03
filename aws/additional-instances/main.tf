provider "aws" {}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  cluster_name = "addinst"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws"
  }

  cluster_name        = "${local.cluster_name}"
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = 1
  num_private_agents = 1
  num_public_agents  = 1

  dcos_variant              = "ee"
  dcos_version              = "1.13.2"
  dcos_license_key_contents = "${file("~/license.txt")}"

  dcos_config = <<EOF
feature_dcos_storage_enabled: true
EOF

  additional_private_agent_ips = ["${module.volumeagent.private_ips}"]
}

module "volumeagent" {
  source  = "dcos-terraform/private-agents/aws"
  version = "~> 0.2.0"

  cluster_name           = "${local.cluster_name}"
  aws_subnet_ids         = ["${module.dcos.infrastructure.vpc.subnet_ids}"]
  aws_security_group_ids = ["${module.dcos.infrastructure.security_groups.internal}"]
  aws_key_name           = "${module.dcos.infrastructure.aws_key_name}"

  aws_extra_volumes = [
    {
      size        = "100"
      type        = "gp2"
      iops        = "3000"
      device_name = "/dev/xvdi"
    },
    {
      size        = "1000"
      type        = ""          # Use AWS default.
      iops        = "0"         # Use AWS default.
      device_name = "/dev/xvdj"
    },
  ]

  num_private_agents = 2
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}
