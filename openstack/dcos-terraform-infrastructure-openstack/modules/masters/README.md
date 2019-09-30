OpenStack DC/OS Master Instances
================================
This module creates typical DC/OS master instances

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| associate\_public\_ip\_address | Associate a public IP address with the instances | string | `"false"` | no |
| cluster\_name | Name of the DC/OS cluster | string | n/a | yes |
| flavor\_name | Flavor (compute, memory, storage capacity)  of instance | string | `"saveloy"` | no |
| floating\_ip\_pool | Subnet from which a floating IP address should be assigned | string | `""` | no |
| hostname\_format | Format the hostname inputs are index+1, region, cluster_name | string | `"%[3]s-master%[1]d-%[2]s"` | no |
| image | The operating system image to be used for the instance | string | `""` | no |
| key\_pair | The name of the SSH key pair to be associated with this instance | string | `""` | no |
| network\_id | The UUID of the network to which the instance will be attached | string | `""` | no |
| num\_masters | Specify the number of master instances.  This should be at least 1 | string | `"1"` | no |
| security\_groups | The security groups (firewall rules) that will be applied to this instance | list | `<list>` | no |
| tags | Add custom tags to all resources | map | `<map>` | no |
| user\_data | User data to be used on this instance (cloud-init) | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| instances | List of instance IDs |
| private\_ips | List of private ip addresses created by this module |
| public\_ips | List of public ip addresses created by this module |

