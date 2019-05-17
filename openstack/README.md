# DC/OS on OpenStack

🚨Work in progress!🚨

The [Terraform](https://www.terraform.io) code and scripts in this repository install and configure [DC/OS](https://dcos.io) on a 'typical' [OpenStack](https://openstack.org) deployment.  Typical in this case means:

* Per-tenant networking, with an external provider network that's used to provide ingress / egress Internet connectivity;
* A pool of floating IP addresses, allocated from this provider network;
* LBaaSv2 is configured and available for use.

There are a number of bugs and limitations, but infrastructure-wise and off the top of my head:

* No block storage service integration;
* No DNS ([Designate DNSaaS](https://docs.openstack.org/designate/latest/) is sadly still relatively rare across OpenStack deployments);
* No multi-region support;
* No SSL.

You will also need a compatible operating system image to use, in this case CentOS 7.6, ideally with Docker pre-installed.  You could add DC/OS pre-requisites such as this via cloud-init at time of bootstrap though if needs be.

It's designed function exactly as per the [DC/OS Universal Installer](https://docs.mesosphere.com/1.13/installing/evaluation/) for other supported platforms, with OpenStack-specific customisations and idiosyncrasies.

No guarantees are made about the utility of the resulting DC/OS deployment, however it's been successfully tested on a couple of public OpenStack deployments including [CityCloud](https://citycloud.com).

## Getting started

As mentioned above, this is designed to be as close as possible to the [official installation method](https://docs.mesosphere.com/1.13/installing/evaluation/aws/).  You'll need the same pre-requisites (Terraform, basically), and you'll also need to configure your environment as if you were using the OpenStack CLI.

Create a folder called `dcos-openstack-demo`, `cd` into it, and then create a file called `main.tf` with the following contents.  You'll need to change a few things depending on your target deployment - the values in the example below worked for me on CityCloud.  Note that image I used was a lightly customised CentOS image with Docker pre-installed:

```terraform
module "dcos" {
  source = "github.com/dcos-terraform/examples//openstack/dcos-terraform-openstack"

  cluster_name        = "yankcrime"
  floating_ip_pool    = "ext-net"
  external_network_id = "9e031103-e161-4e71-8740-24cd16beb239"

  bootstrap_os_user      = "centos"
  masters_os_user        = "centos"
  public_agents_os_user  = "centos"
  private_agents_os_user = "centos"

  ssh_public_key_file = "~/.ssh/id_rsa.pub"

  num_masters        = "1"
  num_private_agents = "3"
  num_public_agents  = "1"

  dcos_version              = "1.13"
  dcos_variant              = "open"
  custom_dcos_download_path = "https://downloads.dcos.io/dcos/stable/1.13.0-beta/dcos_generate_config.sh"

  bootstrap_image     = "CentOS 7.6-docker"
  master_image        = "CentOS 7.6-docker"
  public_agent_image  = "CentOS 7.6-docker"
  private_agent_image = "CentOS 7.6-docker"
  
  bootstrap_flavor_name      = "1C-1GB-20GB"
  masters_flavor_name        = "1C-6GB-20GB"
  private_agents_flavor_name = "1C-2GB-20GB"
  public_agents_flavor_name  = "1C-6GB-20GB"

  public_agents_additional_ports = ["6443", "13000"]
}

variable "dcos_install_mode" {
  description = "specifies which type of command to execute. Options: install or upgrade"
  default     = "install"
}

output "masters-ips" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}
```

Then run the Terraform command to initialise and download the various modules and their dependencies:

``` shell
$ terraform init
Initializing modules...
- module.dcos
- module.dcos.dcos-infrastructure

[..]

Terraform has been successfully initialized!
```

At this point we can do a `plan`:

``` shell
$ terraform plan -out=plan.out
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

[..]

Plan: 68 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

This plan was saved to: plan.out
```

And if all that looks good:

```shell
$ terraform apply "plan.out"
```
After a few minutes and a successful run (🤞!) then Terraform should output the IP address of various resources, you'll then be able to point your browser to the IP address of your cluster in order to be able to login.

## Troubleshooting
The default quota for loadbalancer pools (10) is too low for this deployment to succeed in most cases.  You'll need these bumped with something along the lines of:

```shell
$ neutron quota-update --loadbalancer 100 --pool 100 --listener 100 --tenant-id aa2386f56a02439aa20b4190bde01dea
```




