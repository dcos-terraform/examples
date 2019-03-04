# External Existing VPC Resource Example

This terraform script shows what the minimum requirments are to ensure that this top level terraform example will works if there is no default VPC in your region and if there exist one but doesn't fulfill the requirements listed in the top-level README.md.

## Deploy

  ```bash
  terraform apply
  ```

## Configure

Once when the VPC is deployed, head over to the top level module and provide the output of the `vpc_id` as a variable input to the example.

  ```bash
  # top-level terraform module
  terraform apply -var vpc_id="vpc-xxxxxxxxxxxxxxxx" ...
  ```

## Destroy 

  ```bash
  terraform destroy
  ```
