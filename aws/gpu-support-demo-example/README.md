# GPU Testing Example of Universal Installer

We need a testing example that shows an implementation of GPU support of the universal installer.

This approach leverages a pooled agent module that allows users to select aribitrary modules and configurations that is seperate from the `dcos` module that lives in the main.tf. The example lives in the [main.tf](./main.tf) file. 

### Limitations

* This GPU mesosphere AMI only lives in the `us-west-2` region and can only be run there for the time being.
* This example is using the 0.1.0 of dcos-terraform. There will be a 0.2.0 version coming soon and the main.tf will need to be updated to use this newer module.
* This is for demo and testing purposes only! Do not run in production!
