provider "google" {
  version = "~> 2.0"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

locals {
  cluster_name = "generic-dcos-ee-demo"
}

module "dcos" {
  source  = "dcos-terraform/dcos/gcp"
  version = "~> 0.2.0"

  providers = {
    google = "google"
  }

  cluster_name        = "${local.cluster_name}"
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = "1"
  num_private_agents = "2"
  num_public_agents  = "1"

  dcos_instance_os       = "centos_7"
  bootstrap_machine_type = "n1-standard-4"

  dcos_variant              = "ee"
  dcos_version              = "1.13.1"
  dcos_license_key_contents = "${file("~/license.txt")}"

  # provide a SHA512 hashed password, here "deleteme"
  dcos_superuser_password_hash = "$6$rounds=656000$YSvuFmasQDXheddh$TpYlCxNHF6PbsGkjlK99Pwxg7D0mgWJ.y0hE2JKoa61wHx.1wtxTAHVRHfsJU9zzHWDoE08wpdtToHimNR9FJ/"
  dcos_superuser_username      = "demo-super"
}

output "masters_dns_name" {
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

