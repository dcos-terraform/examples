///////////////// VARIABLES /////////////////
//
// Only ssh_public_key is mandatory
//
////////////////////////////////////////////
variable "ssh_public_key" {
  description = <<EOF
Specify a SSH public key in authorized keys format (e.g. "ssh-rsa ..") to be used with the instances. Make sure you added this key to your ssh-agent
EOF
}

variable "dcos_version" {
  description = "Specify the availability zones to be used"
  default     = "1.12.1"
}

variable "cluster_name" {
  description = "Name of the DC/OS cluster"
  default     = "dcos-default-vpc"
}

variable "num_masters" {
  description = "Specify the amount of masters. For redundancy you should have at least 3"
  default     = 1
}

variable "num_private_agents" {
  description = "Specify the amount of private agents. These agents will provide your main resources"
  default     = 1
}

variable "num_public_agents" {
  description = "Specify the amount of public agents. These agents will host marathon-lb and edgelb"
  default     = 1
}

variable "dcos_license_key_contents" {
  default     = ""
  description = "[Enterprise DC/OS] used to privide the license key of DC/OS for Enterprise Edition. Optional if license.txt is present on bootstrap node."
}

variable "dcos_type" {
  default = "open"
}

variable "tags" {
  description = "Add custom tags to all resources"
  type        = "map"
  default     = {}
}

variable "admin_ips" {
  description = "List of CIDR admin IPs"
  type        = "list"
}

////////////////////////////////////////////
/////////////// END VARIABLES //////////////
////////////////////////////////////////////

provider "aws" {}

// create a ssh-key-pair.
resource "aws_key_pair" "deployer" {
  provider = "aws"

  key_name   = "${var.cluster_name}-deployer-key"
  public_key = "${var.ssh_public_key}"
}

// select our default VPC.
// instead of default you could specify an name or ID.
// https://www.terraform.io/docs/providers/aws/d/vpc.html
data "aws_vpc" "default" {
  provider = "aws"

  default = true
}

// we want to use all the subnets in this VPC
// You could use tags if you only want a subset of subnets
// https://www.terraform.io/docs/providers/aws/d/subnet_ids.html
// For redundancy make sure your subnets are distributed
// across availability zones
data "aws_subnet_ids" "default_subnets" {
  provider = "aws"

  vpc_id = "${data.aws_vpc.default.id}"
}

// we use intermediate local variables. So whenever it is needed to replace
// or drop a modules it is easier to change just the local variable instead
// of all other references
locals {
  key_name     = "${aws_key_pair.deployer.key_name}"
  vpc_id       = "${data.aws_vpc.default.id}"
  subnet_range = "${data.aws_vpc.default.cidr_block}"
  subnet_ids   = ["${data.aws_subnet_ids.default_subnets.ids}"]
}

// Firewall. Create policies for instances and load balancers.
// https://registry.terraform.io/modules/dcos-terraform/security-groups/aws
module "dcos-security-groups" {
  source  = "dcos-terraform/security-groups/aws"
  version = "~> 0.1.0"

  providers = {
    aws = "aws"
  }

  vpc_id       = "${local.vpc_id}"
  subnet_range = "${local.subnet_range}"
  cluster_name = "${var.cluster_name}"
  admin_ips    = ["${var.admin_ips}"]
}

// we use intermediate local variables. So whenever it is needed to replace
// or drop a modules it is easier to change just the local variable instead
// of all other references
locals {
  instance_security_groups             = ["${list(module.dcos-security-groups.internal, module.dcos-security-groups.admin)}"]
  security_groups_elb_masters          = ["${list(module.dcos-security-groups.admin,module.dcos-security-groups.internal)}"]
  security_groups_elb_masters_internal = ["${list(module.dcos-security-groups.internal)}"]
  security_groups_elb_public_agents    = ["${list(module.dcos-security-groups.admin,module.dcos-security-groups.internal)}"]
}

// Permissions creates instances profiles so you could use Rexray and Kubernetes with AWS support
// These set of IAM Rules will be applied as Instance Profiles. They will enable Rexray to maintain
// volumes in your cluster
// https://registry.terraform.io/modules/dcos-terraform/iam/aws
module "dcos-iam" {
  source  = "dcos-terraform/iam/aws"
  version = "~> 0.1.0"

  providers = {
    aws = "aws"
  }

  cluster_name = "${var.cluster_name}"
}

// This spawning the Bootstrap node which will be used as the internal source for the installer.
// https://registry.terraform.io/modules/dcos-terraform/bootstrap/aws
module "dcos-bootstrap-instance" {
  source  = "dcos-terraform/bootstrap/aws"
  version = "~> 0.1.0"

  providers = {
    aws = "aws"
  }

  cluster_name = "${var.cluster_name}"

  aws_subnet_ids         = ["${local.subnet_ids}"]
  aws_security_group_ids = ["${local.instance_security_groups}"]
  aws_key_name           = "${local.key_name}"
  aws_instance_type      = "m5.large"

  tags = "${var.tags}"
}

// This module creates the master instances of your DC/OS cluster. If neccessary you can change the instance type or OS.
// https://registry.terraform.io/modules/dcos-terraform/masters/aws
module "dcos-master-instances" {
  source  = "dcos-terraform/masters/aws"
  version = "~> 0.1.0"

  providers = {
    aws = "aws"
  }

  cluster_name = "${var.cluster_name}"

  aws_subnet_ids         = ["${local.subnet_ids}"]
  aws_security_group_ids = ["${local.instance_security_groups}"]
  aws_key_name           = "${local.key_name}"
  aws_instance_type      = "m5.xlarge"

  num_masters = "${var.num_masters}"

  tags = "${var.tags}"
}

// This module create the private agent instances of your DC/OS cluster. If neccessary you can change the instance type or OS.
// https://registry.terraform.io/modules/dcos-terraform/private-agents/aws
module "dcos-privateagent-instances" {
  source  = "dcos-terraform/private-agents/aws"
  version = "~> 0.1.0"

  providers = {
    aws = "aws"
  }

  cluster_name = "${var.cluster_name}"

  aws_subnet_ids         = ["${local.subnet_ids}"]
  aws_security_group_ids = ["${local.instance_security_groups}"]
  aws_key_name           = "${local.key_name}"
  aws_instance_type      = "m5.large"

  num_private_agents = "${var.num_private_agents}"

  tags = "${var.tags}"
}

// This module create the public agent instances of your DC/OS cluster. If neccessary you can change the instance type or OS.
// https://registry.terraform.io/modules/dcos-terraform/public-agents/aws
module "dcos-publicagent-instances" {
  source  = "dcos-terraform/public-agents/aws"
  version = "~> 0.1.0"

  providers = {
    aws = "aws"
  }

  cluster_name = "${var.cluster_name}"

  aws_subnet_ids         = ["${local.subnet_ids}"]
  aws_security_group_ids = ["${local.instance_security_groups}"]
  aws_key_name           = "${local.key_name}"
  aws_instance_type      = "m5.large"

  num_public_agents = "${var.num_public_agents}"

  tags = "${var.tags}"
}

// we use intermediate local variables. So whenever it is needed to replace
// or drop a modules it is easier to change just the local variable instead
// of all other references
locals {
  bootstrap_ip         = "${module.dcos-bootstrap-instance.public_ip}"
  bootstrap_private_ip = "${module.dcos-bootstrap-instance.private_ip}"
  bootstrap_os_user    = "${module.dcos-bootstrap-instance.os_user}"

  master_ips         = ["${module.dcos-master-instances.public_ips}"]
  master_private_ips = ["${module.dcos-master-instances.private_ips}"]
  masters_os_user    = "${module.dcos-master-instances.os_user}"
  master_instances   = ["${module.dcos-master-instances.instances}"]

  private_agent_ips         = ["${module.dcos-privateagent-instances.public_ips}"]
  private_agent_private_ips = ["${module.dcos-privateagent-instances.private_ips}"]
  private_agents_os_user    = "${module.dcos-privateagent-instances.os_user}"

  public_agent_ips         = ["${module.dcos-publicagent-instances.public_ips}"]
  public_agent_private_ips = ["${module.dcos-publicagent-instances.private_ips}"]
  public_agents_os_user    = "${module.dcos-publicagent-instances.os_user}"
  public_agent_instances   = ["${module.dcos-publicagent-instances.instances}"]
}

// Load balancers is providing three load balancers.
// - public master load balancer
//   this load balancer is meant to be used as your main access to the cluster and will lead you to the DC/OS Frontend.
//   you can specify masters_acm_cert_arn to use an ACM certificate for proper SSL termination.
//   https://registry.terraform.io/modules/dcos-terraform/elb-dcos/aws
// - internal master load balancer
//   this load balancer can be used for accessing the master internally in the cluster.
//   https://registry.terraform.io/modules/dcos-terraform/elb-dcos/aws
// - public agents load balancer
//   This load balancer is meant to be the main public access point into your application. If you use marathon-lb or edge-lb
//   it will make sure your custermers will allways be able to access one of the public agents even if one failed.
//   you can specify masters_acm_cert_arn to use an ACM certificate for proper SSL termination.
//   https://registry.terraform.io/modules/dcos-terraform/elb-dcos/aws

module "dcos-lb" {
  source  = "dcos-terraform/lb-dcos/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws"
  }

  cluster_name = "${var.cluster_name}"
  subnet_ids   = ["${data.aws_subnet_ids.default_subnets.ids}"]

  security_groups_masters          = ["${local.security_groups_elb_masters}"]
  security_groups_masters_internal = ["${local.security_groups_elb_masters_internal}"]
  security_groups_public_agents    = ["${local.security_groups_elb_public_agents}"]

  master_instances       = ["${module.dcos-master-instances.instances}"]
  public_agent_instances = ["${module.dcos-publicagent-instances.instances}"]

  num_masters       = "${var.num_masters}"
  num_public_agents = "${var.num_public_agents}"

  tags = "${var.tags}"
}

// we use intermediate local variables. So whenever it is needed to replace
// or drop a modules it is easier to change just the local variable instead
// of all other references
locals {
  elb_masters_dns_name = "${module.dcos-lb.masters_dns_name}"
}

// DC/OS Install module takes a list of public and private ip addresses of each of the node type to install.
// - <node type>_ip - This is the "public" address of the given node type. Public in this case mean the address is reachable from the system running terraform. Public and private address could be the same.
// - <node type>_private_ip - These are the addresses the cluster could reach its nodes internally.
// - <node type>_os_user - specifies the user used for sshing into the nodes.
// https://registry.terraform.io/modules/dcos-terraform/dcos-install-remote-exec/null
// DC/OS Options. Install takes also all the options for runnign Genconfig. Whatever you want to change at the DC/OS config needs to be
// specified in this module. A good description could be found here: https://registry.terraform.io/modules/dcos-terraform/dcos-core/template
module "dcos-install" {
  source  = "dcos-terraform/dcos-install-remote-exec/null"
  version = "~> 0.1.0"

  # bootstrap
  bootstrap_ip         = "${local.bootstrap_ip}"
  bootstrap_private_ip = "${local.bootstrap_private_ip}"
  bootstrap_os_user    = "${local.bootstrap_os_user}"

  # master
  master_ips         = ["${local.master_ips}"]
  master_private_ips = ["${local.master_private_ips}"]
  masters_os_user    = "${local.masters_os_user}"
  num_masters        = "${var.num_masters}"

  # private agent
  private_agent_ips         = ["${local.private_agent_ips}"]
  private_agent_private_ips = ["${local.private_agent_private_ips}"]
  private_agents_os_user    = "${local.private_agents_os_user}"
  num_private_agents        = "${var.num_private_agents}"

  # public agent
  public_agent_ips         = ["${local.public_agent_ips}"]
  public_agent_private_ips = ["${local.public_agent_private_ips}"]
  public_agents_os_user    = "${local.public_agents_os_user}"
  num_public_agents        = "${var.num_public_agents}"

  # DC/OS options
  dcos_cluster_name = "${var.cluster_name}"
  dcos_version      = "${var.dcos_version}"

  dcos_ip_detect_public_contents = <<EOF
#!/bin/sh
set -o nounset -o errexit

curl -fsSL http://whatismyip.akamai.com/
EOF

  dcos_ip_detect_contents = <<EOF
#!/bin/sh
# Example ip-detect script using an external authority
# Uses the AWS Metadata Service to get the node's internal
# ipv4 address
curl -fsSL http://169.254.169.254/latest/meta-data/local-ipv4
EOF

  dcos_fault_domain_detect_contents = <<EOF
#!/bin/sh
set -o nounset -o errexit

METADATA="$(curl http://169.254.169.254/latest/dynamic/instance-identity/document 2>/dev/null)"
REGION=$(echo $METADATA | grep -Po "\"region\"\s+:\s+\"(.*?)\"" | cut -f2 -d:)
ZONE=$(echo $METADATA | grep -Po "\"availabilityZone\"\s+:\s+\"(.*?)\"" | cut -f2 -d:)

echo "{\"fault_domain\":{\"region\":{\"name\": \"$REGION\"},\"zone\":{\"name\": \"$ZONE\"}}}"
EOF

  dcos_variant                   = "${var.dcos_type}"
  dcos_license_key_contents      = "${var.dcos_license_key_contents}"
  dcos_master_discovery          = "static"
  dcos_exhibitor_storage_backend = "static"
}

output "elb.masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${local.elb_masters_dns_name}"
}
