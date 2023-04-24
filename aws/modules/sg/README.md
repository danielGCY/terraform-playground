# Module: asg

### Purpose

This module creates a security group with the specified ingress and egress rules.

It creates the following resources

- aws_security_group
- aws_vpc_security_group_ingress_rules
- aws_vpc_security_group_egress_rules

### Inputs

This module requires the following inputs:

| Variable               | Type                | Description                                                                                                                                                                                                                                             |
| ---------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| region                 | String              | AWS region eg. us-west-2                                                                                                                                                                                                                                |
| use_name_prefix        | Boolean             | Specify whether to use `name_prefix` or `name` when creating the security group. Defaults to `false`                                                                                                                                                    |
| name                   | String              | Security group name. Ignored if `use_name_prefix` is `true`. Defaults to "default"                                                                                                                                                                      |
| name_prefix            | String              | Security group name prefix. Ignnore if `use_name_prefix` is `false`. Defaults to "default"                                                                                                                                                              |
| description            | String              | Description for the security group                                                                                                                                                                                                                      |
| vpc_id                 | String              | AWS resource ID for the VPC to associate the cluster with                                                                                                                                                                                               |
| revoke_rules_on_delete | Boolean             | Specify whether to delete rules associated with the security group when deleting the security group. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#revoke_rules_on_delete) for more information |
| ingress_rules          | List[Object]        | List of objects specifying ingress rules. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) for more information                                                                  |
| egress_rules           | List[Object]        | List of objects specifying egress rules. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) for more information                                                                    |
| tags                   | Map[String, String] | Tags to tag the security group                                                                                                                                                                                                                          |

### Usage

To use this module, specify the source with the required inputs:

```terraform
module "my_sg" {
  source = "./sg"
  name   = "test"
  region = "ap-southeast-2"
  ingress_rules = [
    {
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all inbound connections"
      ip_protocol = "ALL"
    }
  ]
  egress_rules = [
    {
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound connections"
      ip_protocol = "ALL"
    }
  ]
}
```

### Outputs

Once the module has completed you can access the following:

| Variable | Type   | Description                                        |
| -------- | ------ | -------------------------------------------------- |
| id       | String | AWS resource ID of the provisioned security group  |
| arn      | String | AWS resource ARN of the provisioned security_group |

This can be done by referencing the instance like so:

```terraform
module "sample" {
  source          = "./sample"
  input_variables = module.my_sg.id
  ...
}
```
