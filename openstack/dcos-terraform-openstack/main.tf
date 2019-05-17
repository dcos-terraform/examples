/**
 * DC/OS on OpenStack
 * ==================
 * Creates a DC/OS Cluster on a typical OpenStack installation
*/

module "dcos-infrastructure" {
  source = "github.com/dcos-terraform/examples//openstack/dcos-terraform-infrastructure-openstack"

  cluster_name        = "${var.cluster_name}"
  floating_ip_pool    = "${var.floating_ip_pool}"
  external_network_id = "${var.external_network_id}"
  ssh_public_key_file = "${var.ssh_public_key_file}"

  bootstrap_image     = "${var.bootstrap_image}"
  master_image        = "${var.master_image}"
  public_agent_image  = "${var.public_agent_image}"
  private_agent_image = "${var.private_agent_image}"

  bootstrap_flavor_name      = "${var.bootstrap_flavor_name}"
  masters_flavor_name        = "${var.masters_flavor_name}"
  private_agents_flavor_name = "${var.private_agents_flavor_name}"
  public_agents_flavor_name  = "${var.public_agents_flavor_name}"

  public_agents_additional_ports = "${var.public_agents_additional_ports}"

  num_masters        = "${var.num_masters}"
  num_private_agents = "${var.num_private_agents}"
  num_public_agents  = "${var.num_public_agents}"

  user_data = "${var.user_data}"
}

module "dcos-install" {
  source = "dcos-terraform/dcos-install-remote-exec/null"

  version = "~> 0.2.0"

  # bootstrap
  bootstrap_ip         = "${module.dcos-infrastructure.bootstrap.public_ip}"
  bootstrap_private_ip = "${module.dcos-infrastructure.bootstrap.private_ip}"
  bootstrap_os_user    = "${var.bootstrap_os_user}"

  # master
  master_ips         = ["${module.dcos-infrastructure.masters.public_ips}"]
  master_private_ips = ["${module.dcos-infrastructure.masters.private_ips}"]
  masters_os_user    = "${var.masters_os_user}"
  num_masters        = "${var.num_masters}"

  # private agent
  private_agent_ips         = ["${module.dcos-infrastructure.private_agents.public_ips}"]
  private_agent_private_ips = ["${module.dcos-infrastructure.private_agents.private_ips}"]
  private_agents_os_user    = "${var.private_agents_os_user}"
  num_private_agents        = "${var.num_private_agents}"

  # public agent
  public_agent_ips         = ["${module.dcos-infrastructure.public_agents.public_ips}"]
  public_agent_private_ips = ["${module.dcos-infrastructure.public_agents.private_ips}"]
  public_agents_os_user    = "${var.public_agents_os_user}"
  num_public_agents        = "${var.num_public_agents}"

  # DC/OS options
  dcos_cluster_name                            = "${var.cluster_name}"
  custom_dcos_download_path                    = "${var.custom_dcos_download_path}"
  dcos_adminrouter_tls_1_0_enabled             = "${var.dcos_adminrouter_tls_1_0_enabled}"
  dcos_adminrouter_tls_1_1_enabled             = "${var.dcos_adminrouter_tls_1_1_enabled}"
  dcos_adminrouter_tls_1_2_enabled             = "${var.dcos_adminrouter_tls_1_2_enabled}"
  dcos_adminrouter_tls_cipher_suite            = "${var.dcos_adminrouter_tls_cipher_suite}"
  dcos_agent_list                              = ["${var.dcos_agent_list}"]
  dcos_audit_logging                           = "${var.dcos_audit_logging}"
  dcos_auth_cookie_secure_flag                 = "${var.dcos_auth_cookie_secure_flag}"
  dcos_bootstrap_port                          = "${var.dcos_bootstrap_port}"
  dcos_bouncer_expiration_auth_token_days      = "${var.dcos_bouncer_expiration_auth_token_days}"
  dcos_ca_certificate_chain_path               = "${var.dcos_ca_certificate_chain_path}"
  dcos_ca_certificate_key_path                 = "${var.dcos_ca_certificate_key_path}"
  dcos_ca_certificate_path                     = "${var.dcos_ca_certificate_path}"
  dcos_check_time                              = "${var.dcos_check_time}"
  dcos_cluster_docker_credentials              = "${var.dcos_cluster_docker_credentials}"
  dcos_cluster_docker_credentials_dcos_owned   = "${var.dcos_cluster_docker_credentials_dcos_owned}"
  dcos_cluster_docker_credentials_enabled      = "${var.dcos_cluster_docker_credentials_enabled}"
  dcos_cluster_docker_credentials_write_to_etc = "${var.dcos_cluster_docker_credentials_write_to_etc}"
  dcos_cluster_docker_registry_enabled         = "${var.dcos_cluster_docker_registry_enabled}"
  dcos_cluster_docker_registry_url             = "${var.dcos_cluster_docker_registry_url}"
  dcos_config                                  = "${var.dcos_config}"
  dcos_custom_checks                           = "${var.dcos_custom_checks}"
  dcos_customer_key                            = "${var.dcos_customer_key}"
  dcos_dns_bind_ip_blacklist                   = "${var.dcos_dns_bind_ip_blacklist}"
  dcos_dns_forward_zones                       = "${var.dcos_dns_forward_zones}"
  dcos_dns_search                              = "${var.dcos_dns_search}"
  dcos_docker_remove_delay                     = "${var.dcos_docker_remove_delay}"
  dcos_enable_docker_gc                        = "${var.dcos_enable_docker_gc}"
  dcos_enable_gpu_isolation                    = "${var.dcos_enable_gpu_isolation}"
  dcos_exhibitor_address                       = "${var.dcos_exhibitor_address}"
  dcos_exhibitor_explicit_keys                 = "${var.dcos_exhibitor_explicit_keys}"
  dcos_exhibitor_storage_backend               = "${var.dcos_exhibitor_storage_backend}"
  dcos_exhibitor_zk_hosts                      = "${var.dcos_exhibitor_zk_hosts}"
  dcos_exhibitor_zk_path                       = "${var.dcos_exhibitor_zk_path}"
  dcos_fault_domain_detect_contents            = "${coalesce(var.dcos_fault_domain_detect_contents, file("${path.module}/scripts/fault-domain-detect.sh"))}"
  dcos_fault_domain_enabled                    = "${var.dcos_fault_domain_enabled}"
  dcos_gc_delay                                = "${var.dcos_gc_delay}"
  dcos_gpus_are_scarce                         = "${var.dcos_gpus_are_scarce}"
  dcos_http_proxy                              = "${var.dcos_http_proxy}"
  dcos_https_proxy                             = "${var.dcos_https_proxy}"
  dcos_ip_detect_contents                      = "${coalesce(var.dcos_ip_detect_contents,file("${path.module}/scripts/ip-detect.sh"))}"
  dcos_ip_detect_public_contents               = "${coalesce(var.dcos_ip_detect_public_contents,file("${path.module}/scripts/ip-detect-public.sh"))}"
  dcos_ip_detect_public_filename               = "${var.dcos_ip_detect_public_filename}"
  dcos_l4lb_enable_ipv6                        = "${var.dcos_l4lb_enable_ipv6}"
  dcos_license_key_contents                    = "${var.dcos_license_key_contents}"
  dcos_log_directory                           = "${var.dcos_log_directory}"
  dcos_master_discovery                        = "${var.dcos_master_discovery}"
  dcos_master_dns_bindall                      = "${var.dcos_master_dns_bindall}"
  dcos_master_external_loadbalancer            = "${coalesce(var.dcos_master_external_loadbalancer,module.dcos-infrastructure.lb.masters)}"
  dcos_master_list                             = "${var.dcos_master_list}"
  dcos_mesos_container_log_sink                = "${var.dcos_mesos_container_log_sink}"
  dcos_mesos_dns_set_truncate_bit              = "${var.dcos_mesos_dns_set_truncate_bit}"
  dcos_mesos_max_completed_tasks_per_framework = "${var.dcos_mesos_max_completed_tasks_per_framework}"
  dcos_no_proxy                                = "${var.dcos_no_proxy}"
  dcos_num_masters                             = "${var.dcos_num_masters}"
  dcos_oauth_enabled                           = "${var.dcos_oauth_enabled}"
  dcos_overlay_config_attempts                 = "${var.dcos_overlay_config_attempts}"
  dcos_overlay_enable                          = "${var.dcos_overlay_enable}"
  dcos_overlay_mtu                             = "${var.dcos_overlay_mtu}"
  dcos_overlay_network                         = "${var.dcos_overlay_network}"
  dcos_package_storage_uri                     = "${var.dcos_package_storage_uri}"
  dcos_previous_version                        = "${var.dcos_previous_version}"
  dcos_previous_version_master_index           = "${var.dcos_previous_version_master_index}"
  dcos_process_timeout                         = "${var.dcos_process_timeout}"
  dcos_public_agent_list                       = ["${var.dcos_public_agent_list}"]
  dcos_resolvers                               = "${var.dcos_resolvers}"
  dcos_rexray_config                           = "${var.dcos_rexray_config}"
  dcos_rexray_config_filename                  = "${var.dcos_rexray_config_filename}"
  dcos_rexray_config_method                    = "${var.dcos_rexray_config_method}"
  dcos_s3_bucket                               = "${var.dcos_s3_bucket}"
  dcos_s3_prefix                               = "${var.dcos_s3_prefix}"
  dcos_security                                = "${var.dcos_security}"
  dcos_skip_checks                             = "${var.dcos_skip_checks}"
  dcos_staged_package_storage_uri              = "${var.dcos_staged_package_storage_uri}"
  dcos_superuser_password_hash                 = "${var.dcos_superuser_password_hash}"
  dcos_superuser_username                      = "${var.dcos_superuser_username}"
  dcos_telemetry_enabled                       = "${var.dcos_telemetry_enabled}"
  dcos_variant                                 = "${var.dcos_variant}"
  dcos_ucr_default_bridge_subnet               = "${var.dcos_ucr_default_bridge_subnet}"
  dcos_use_proxy                               = "${var.dcos_use_proxy}"
  dcos_version                                 = "${var.dcos_version}"
  dcos_zk_agent_credentials                    = "${var.dcos_zk_agent_credentials}"
  dcos_zk_master_credentials                   = "${var.dcos_zk_master_credentials}"
  dcos_zk_super_credentials                    = "${var.dcos_zk_super_credentials}"
  dcos_enable_mesos_input_plugin               = "${var.dcos_enable_mesos_input_plugin}"
}
