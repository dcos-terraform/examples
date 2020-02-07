BETA STATE
This is an early example how to use and integrate windows agents. If you're not an active developer of this project we do not suggest to use it.

Usage
In order to spin up a DC/OS cluster with extra Windows agents, use the latest main.tf and specify number of Windows agents at num field.

Currently main.tf contains ansible_bundled_container parameter which refers to a docker image with windows related changes (tag feature-windows-support-${commit} indicates about it).

terraform init -upgrade
terraform apply
wait for the cluster to be spawned. It will also spin up a windows instance and uses the ansible_bundled_container docker image.

The ansible_bundled_container can be replaced with your own provided docker image, to test the ansible run which is fully integrated into the terraform apply process. It will be pulled onto the bootstrap node and being executed there.

The mesospbhere image can be found at mesosphere/dcos-ansible-bundle