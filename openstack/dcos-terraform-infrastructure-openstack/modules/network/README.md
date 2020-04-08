DC/OS OpenStack Network
=======================
This module creates the network infrastructure necessary for DC/OS
on OpenStack

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster\_name | Name of the DC/OS cluster | string | n/a | yes |
| external\_network\_id | The ID of the external network providing ingress / egress | string | `""` | no |
| subnet\_range | Private IP space to be used in CIDR format | string | `"172.31.0.0/16"` | no |
| tags | Add custom tags to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| network\_id | UUID of the network |
| subnet\_id | UUID of the subnet |

