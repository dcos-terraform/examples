# ALPHA STATE - DO NOT USE THIS EXAMPLE

This is an early example how to use and integrate windows agents. If you're not
an active developer of this project we do not suggest to use it.

## Ansible run not yet fully integrated.

You need our Terraformfile based terraform 0.11 fork: https://github.com/fatz/terraform/releases/tag/v0.11.14-mesosphere

```
terraform init -upgrade
terraform apply
```

wait for the cluster to be spawned. It will also spin up a windows instance but it is not yet installed.

To install it we use the by terraform generated inventory file `./inventory` and the dcos-ansible windows branch.

```
git clone git@github.com:dcos/dcos-ansible.git
cd dcos-ansible
git fetch && git checkout feature/windows-support
cp group_vars/all/dcos.yaml.example group_vars/all/dcos.yaml
```

make sure you've ansible and winrm support installed
```
pip install ansible==2.7.8 jmespath pywinrm==0.3.0
```

now you can run ansible with the provided inventory file
```
ansible-playbook -vvv -i ../inventory -l agents_windows dcos.yml -e /group_vars/all/dcos.yaml
```
