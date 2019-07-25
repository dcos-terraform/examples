# Windows Agent support (Alpha state example)

This is an early example how to use and integrate windows agents. If you're not
an active developer of this project we do not suggest to use it.

## Usage
In order to get Windows instance span up, use latest `main.tf` and specify number of Windows Agents at `num` field.
Currently `main.tf` contains `ansible_bundled_container` parameter which refers 
to docker image with windows-related changes (tag `feature-windows-support-${commit}` indicates about it).

The proper image can be found at [mesosphere/dcos-ansible-bundle](https://hub.docker.com/r/mesosphere/dcos-ansible-bundle/tags)
For instance, `ansible_bundled_container = "mesosphere/dcos-ansible-bundle:feature-windows-support-039d79d"` 

The `ansible_bundled_container` can be replaced with your own provided docker image, to test the ansible run
which is fully integrated into the terraform apply process. 
It will be pulled onto the bootstrap node and being executed there.