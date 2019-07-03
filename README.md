# DC/OS Terraform advanced examples
This repository contains advanced methods of using the underlying modules of the DC/OS Universal Installer.

For production usage make sure you understand how terraform works and stores its state.

## Examples

###### *Simple*: Simple setup of DC/OS.
- [AWS](aws/simple/)
- [Azure](azure/simple/)
- [GCP](gcp/simple/)

###### *Existing VPC*: Using an already existing VPC.
- [AWS](aws/existing-vpc/)

###### *Additional Instances*: Provisioning extra agent nodes with another disk configuration.
- [AWS](aws/additional-instances/)
- [Azure](azure/additional-instances/)
- [GCP](gcp/additional-instances/)

###### *Remote Region*: Using remote regions.
- [AWS](aws/remote-region/)
- [Azure](azure/remote-region/)
- [GCP](gcp/remote-region/)

###### *GPU Agent*: Using agent instances providing GPU.
- [AWS](aws/gpu-agent/)
- [Azure](azure/gpu-agent/)
- [GCP](gcp/gpu-agent/)
