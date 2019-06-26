# DC/OS Terraform advanced examples
This repository contains advanced methods of using the underlying modules of the DC/OS Universal Installer.

For production usage make sure you understand how terraform works and stores its state.

## Examples

- AWS
  - [Windows-agent](aws/windows-agent) - An  example with  windows agent support
  - [Simple](aws/simple/) - An example for a simple setup of DC/OS.
  - [Existing VPC](aws/existing-vpc/) - An example using an already existing VPC.
  - [Additional Instances](aws/additional-instances/) - An example for provisioning extra agent nodes with another disk configuration.
  - [Remote Region](aws/remote-region/) - An example for using remote regions.
- GCP
  - [Simple](gcp/simple/) - An example for a simple setup of DC/OS.
  - [Additional Instances](gcp/additional-instances/) - An example for provisioning extra agent nodes with another disk configuration.
