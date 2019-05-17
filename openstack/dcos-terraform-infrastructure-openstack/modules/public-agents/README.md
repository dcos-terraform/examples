OpenStack DC/OS Public Agent Instances
======================================
This module creates typical DC/OS public agent instances

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| associate\_public\_ip\_address | Associate a public IP address with the instances | string | `"true"` | no |
| cluster\_name | Name of the DC/OS cluster | string | n/a | yes |
| flavor\_name | Flavor (compute, memory, storage capacity)  of instance | string | `"bratwurst"` | no |
| floating\_ip\_pool | Subnet from which a floating IP address should be assigned | string | `""` | no |
| hostname\_format | Format the hostname inputs are index+1, region, cluster_name | string | `"%[3]s-publicagent%[1]d-%[2]s"` | no |
| image | The operating system image to be used for the instance | string | `""` | no |
| key\_pair | The name of the SSH key pair to be associated with this instance | string | `""` | no |
| network\_id | The UUID of the network to which the instance will be attached | string | `""` | no |
| num\_public\_agents | Specify the number of public agents.  These agents will host marathon-lb and edgelb | string | `"1"` | no |
| security\_groups | The security groups (firewall rules) that will be applied to this instance | list | `<list>` | no |
| tags | Add custom tags to all resources | map | `<map>` | no |
| user\_data | User data to be used on this instance (cloud-init) | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| instances | Public Agent instances IDs |
| private\_ips | Public Agent instances private IPs |
| public\_ips | Public Agent public IPs |

