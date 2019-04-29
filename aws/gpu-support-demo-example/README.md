# GPU Testing Example of Universal Installer

We need a testing example that shows an implementation of GPU support of the universal installer.

This approach leverages a pooled agent module that allows users to select aribitrary modules and configurations that is seperate from the `dcos` module that lives in the main.tf. The example lives in these places below for the main.tf file:

 * [dcos-terraform-v0.1-gpu-main.tf](./dcos-terraform-v0.1-gpu-main.tf)
 * [dcos-terraform-v0.2-gpu-main.tf](./dcos-terraform-v0.2-gpu-main.tf)
 * [dcos-terraform-v0.2-gpu-multi-region-main.tf](./dcos-terraform-v0.2-gpu-multi-region-main.tf)

### Limitations

* This GPU mesosphere AMI only lives in the `us-west-2` region and can only be run there for the time being.
* This is for demo and testing purposes only! Do not run in production!
