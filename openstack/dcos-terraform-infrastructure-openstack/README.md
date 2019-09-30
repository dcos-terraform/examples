DC/OS on OpenStack
==================
This module creates typical DS/OS infrastructure on OpenStack.

Known Issues
------------

No support (yet) for block storage
No support (yet) for configuring TLS
No support (yet) for multiple regions

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bootstrap\_associate\_public\_ip\_address | Associate a public ip address with boostrap instances | string | `"true"` | no |
| bootstrap\_flavor\_name | The name of the flavor used for the bootstrap instance | string | `""` | no |
| bootstrap\_image | OS image to be used for bootstrap node | string | n/a | yes |
| cluster\_name | Name of the DC/OS cluster | string | n/a | yes |
| dcos\_instance\_os | Operating system to use. | string | `"CentOS 7.6-docker"` | no |
| external\_network\_id | The UUID of the external network | string | n/a | yes |
| floating\_ip\_pool | The name of the pool of addresses from which floating IPs can be allocated | string | n/a | yes |
| internal\_services |  | list | `<list>` | no |
| master\_image | OS image to be used for master nodes | string | n/a | yes |
| masters\_associate\_public\_ip\_address | Associate a public ip address with master instances | string | `"false"` | no |
| masters\_flavor\_name | The name of the flavor used for the bootstrap instance | string | `""` | no |
| num\_masters |  | string | `""` | no |
| num\_private\_agents |  | string | `""` | no |
| num\_public\_agents |  | string | `""` | no |
| private\_agent\_image | OS image to be used for private agent nodes | string | n/a | yes |
| private\_agents\_associate\_public\_ip\_address | Associate a public ip address with private agent instances | string | `"false"` | no |
| private\_agents\_flavor\_name | The name of the flavor used for the bootstrap instance | string | `""` | no |
| public\_agent\_image | OS image to be used for public agent nodes | string | n/a | yes |
| public\_agents\_additional\_ports | List of additional ports allowed for public access on public agents | list | `<list>` | no |
| public\_agents\_associate\_public\_ip\_address | Associate a public ip address with public agent instances | string | `"true"` | no |
| public\_agents\_flavor\_name | The name of the flavor used for the bootstrap instance | string | `""` | no |
| ssh\_key\_pair |  | string | `"deadline"` | no |
| ssh\_public\_key | SSH public key in authorized keys format (e.g. 'ssh-rsa ..') to be used with the instances. Make sure you added this key to your ssh-agent. | string | `""` | no |
| ssh\_public\_key\_file | Path to SSH public key. This is mandatory but can be set to an empty string if you want to use ssh_public_key with the key as string. | string | n/a | yes |
| subnet\_range | Private IP space to be used in CIDR format | string | `"172.16.0.0/16"` | no |
| user\_data | User data to be used on this instance (cloud-init) | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| bootstrap.instance | Bootstrap instance ID |
| bootstrap.private\_ip | Private IP of the bootstrap instance |
| bootstrap.public\_ip | Public IP of the bootstrap instance |
| lb.masters | Public IP address of masters loadbalancer |
| lb.masters.private\_ip | Public IP address of masters loadbalancer |
| lb.public\_agents | Public agents loadbalancer external IP address |
| masters.instances | Master instances IDs |
| masters.private\_ips | Master instances private IPs |
| masters.public\_ips | Master instances public IPs |
| private\_agents.private\_ips | Private agents public IP addresses |
| private\_agents.public\_ips | Private agents public IP addresses |
| public\_agents.private\_ips | Public agents public IP addresses |
| public\_agents.public\_ips | Public agents public IP addresses |

