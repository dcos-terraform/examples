## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dcos\_masters\_ip\_addresses |  | list | `<list>` | no |
| internal\_services |  | list | `<list>` | no |
| network\_id | The network ID in which the loadbalancer should sit | string | `""` | no |
| num\_masters |  | string | `""` | no |
| security\_group\_id | The security groups (firewall rules) that will be applied to this loadbalancer | list | `<list>` | no |
| subnet\_id | The subnet ID in which lb members should reside | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| public\_ip | Public IP address of the load balancer used to access masters |

