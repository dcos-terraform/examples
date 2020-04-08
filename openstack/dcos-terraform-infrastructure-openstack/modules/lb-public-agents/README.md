## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dcos\_public\_agents\_ip\_addresses |  | list | `<list>` | no |
| network\_id | The network ID in which the loadbalancer should sit | string | `""` | no |
| num\_public\_agents |  | string | `""` | no |
| public\_agents\_additional\_ports | List of additional ports allowed for public access on public agents | list | `<list>` | no |
| public\_agents\_default\_ports |  | list | `<list>` | no |
| security\_group\_id | The security group (firewall rules) that will be applied to this loadbalancer | string | `""` | no |
| subnet\_id | The subnet ID in which lb members should reside | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| public\_ip | Public IP address of the load balancer used to public agents |

