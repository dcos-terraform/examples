# Create a DC/OS Cluster using an existing VPC
In this example, we will create a DC/OS cluster using an already existing VPC. The `main.tf` file in this repository is our example implementation using the default VPC which is predefined in an account.

## Required Variables
- `admin_ips` List of CIDR addresses who get access to the cluster.
- `ssh_public_key` SSH public key to be used for deploying the cluster.

## Infrastructure Assumptions
- A default VPC within a given region
- You have at LEAST 1 subnet within that VPC

## Suggested commands

```bash
$ terraform init
$ terraform plan -var "admin_ips=[\"$(curl http://whatismyip.akamai.com)/32\"]" -var "ssh_public_key=\"$(cat ~/.ssh/id_rsa.pub)\"" -out cluster.plan
$ AWS_DEFAULT_REGION=<region> terraform apply "cluster.plan"
```

## Local Variables
We've added intermediate local variables for all module output and inputs. This will make it easy replacing parts of the modules with your own code.

### Example
In this example you see the local variable `elb_masters_dns_name` is used as in input in the end instead of directly mentioning `module.dcos-elb.masters_dns_name` the benefit of this is you can replace this variable with a static string or with a completely different output. E.g. a data resources of an already existing load balancer.

```hcl
module "dcos-elb" {
  source  = "dcos-terraform/elb-dcos/aws"
  version = "~> 0.0"

  providers = {
    aws = "aws"
  }

  ...

  tags = "${var.tags}"
}

locals {
  elb_masters_dns_name = "${module.dcos-elb.masters_dns_name}"
}

output "elb.masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${local.elb_masters_dns_name}"
}
