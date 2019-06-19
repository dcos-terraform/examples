provider "google" {
  version = "~> 2.0"
  region  = "us-west1"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

data "google_compute_zones" "available" {}

locals {
  ssh_public_key_file       = "~/.ssh/id_rsa.pub"
  cluster_name              = "gpuinst-dcos-ee-demo"
  dcos_license_key_contents = "${file("~/license.txt")}"
  dcos_instance_os          = "centos_7"
  dcos_variant              = "ee"
  dcos_version              = "1.13.1"

  # Check https://cloud.google.com/compute/docs/gpus for available zones
  gpu_zone = ["us-west1-b"]
}

module "dcos" {
  source  = "dcos-terraform/dcos/gcp"
  version = "~> 0.2.0"

  providers = {
    google = "google"
  }

  cluster_name        = "${local.cluster_name}"
  ssh_public_key_file = "${local.ssh_public_key_file}"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = 1
  num_private_agents = 1
  num_public_agents  = 1

  dcos_instance_os       = "${local.dcos_instance_os}"
  bootstrap_machine_type = "n1-standard-4"

  dcos_variant              = "${local.dcos_variant}"
  dcos_version              = "${local.dcos_version}"
  dcos_license_key_contents = "${local.dcos_license_key_contents}"

  # provide a SHA512 hashed password, here "deleteme"
  dcos_superuser_password_hash = "$6$rounds=656000$YSvuFmasQDXheddh$TpYlCxNHF6PbsGkjlK99Pwxg7D0mgWJ.y0hE2JKoa61wHx.1wtxTAHVRHfsJU9zzHWDoE08wpdtToHimNR9FJ/"
  dcos_superuser_username      = "demo-super"

  additional_private_agent_ips = ["${module.gpuagent.private_ips}"]
}

module "gpuagent" {
  source  = "dcos-terraform/private-agents/gcp"
  version = "~> 0.2.0"

  dcos_instance_os = "${local.dcos_instance_os}"
  public_ssh_key   = "${local.ssh_public_key_file}"
  machine_type     = "n1-standard-8"

  cluster_name                  = "${local.cluster_name}"
  hostname_format               = "%[3]s-gpuinstpriv%[1]d-%[2]s"
  private_agent_subnetwork_name = "${module.dcos.infrastructure.private_agents.subnetwork_name}"
  ssh_user                      = "${module.dcos.infrastructure.private_agents.os_user}"
  zone_list                     = "${local.gpu_zone}"
  scheduling_preemptible        = true
  guest_accelerator_type        = "nvidia-tesla-k80"
  guest_accelerator_count       = 1

  num_private_agents = 1
}

output "masters_dns_name" {
  description = "This is the load balancer address to access the DC/OS UI"
  value       = "${module.dcos.masters-loadbalancer}"
}
