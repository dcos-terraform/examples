provider "aws" {}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.1.0"

  providers = {
    aws = "aws"
  }

  cluster_name        = "julfertsv02"
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = "1"
  num_private_agents = "2"
  num_public_agents  = "1"

  #  private_agents_extra_volumes = [{
  #    size        = "100"
  #    type        = "gp2"
  #    iops        = "3000"
  #    device_name = "/dev/xvdi"
  #  }]

  dcos_variant              = "ee"
  dcos_version              = "1.12.2"
  #custom_dcos_download_path         = "https://downloads.mesosphere.com/dcos-enterprise/stable/1.10.9/dcos_generate_config.ee.sh"
  dcos_license_key_contents = "${file("~/license.txt")}"
  dcos_install_mode         = "install"
}

output "elb.masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}

#provider "dcos" {}
#
#resource "dcos_job" "testjob1" {
#  jobid = "testjob1"
#
#  run {
#    disk = 50
#    cpus = 0.1
#    mem  = 128
#    cmd  = "echo testjob1"
#  }
#
#  description = "testjob1 description"
#}

