OpenStack LB DC/OS
==================
This module creates three load balancers for DC/OS.

External masters application load balancer
------------------------------------------
This load balancer keeps an redundant entry point to the masters

Internal masters network load balancer
--------------------------------------
this load balancer is used for internal communication to masters

External public agents network load balancer
--------------------------------------------
This load balancer keeps a single entry point to your public agents no matter how many you're running.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dcos\_masters\_ip\_addresses |  | list | `<list>` | no |
| dcos\_public\_agents\_ip\_addresses |  | list | `<list>` | no |
| masters\_lb\_security\_group\_id |  | list | `<list>` | no |
| network\_id |  | string | `""` | no |
| num\_masters |  | string | `""` | no |
| num\_public\_agents |  | string | `""` | no |
| public\_agents\_additional\_ports | List of additional ports allowed for public access on public agents | list | `<list>` | no |
| public\_agents\_lb\_security\_group\_id |  | string | `""` | no |
| security\_group\_id |  | list | `<list>` | no |
| subnet\_id |  | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| lb\_masters.private\_ip | Private (internal) IP address of the load balancer used for masters |
| lb\_masters.public\_ip | Public IP address of the load balancer used to public agents |
| lb\_public\_agents.public\_ip | Public IP address of the load balancer used to public agents |

