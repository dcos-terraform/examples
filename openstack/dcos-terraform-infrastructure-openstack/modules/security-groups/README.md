## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin\_ips | List of CIDR admin IPs | string | `"0.0.0.0/0"` | no |
| cluster\_name | Name of the DC/OS cluster | string | `"openstack-example"` | no |
| public\_agents\_access\_ips | List of ips allowed access to public agents. | string | `"0.0.0.0/0"` | no |
| public\_agents\_additional\_ports | List of additional ports allowed for public access on public agents (80 and 443 open by default) | list | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| admin | UUID of security group for admin access |
| internal | UUID of security group for internal access |
| master\_lb | UUID of security group for masters load balacer |
| public\_agents | UUID of security group for public agents load balancer |

