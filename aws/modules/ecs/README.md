# Module: asg

### Purpose

This module creates a generic ecs cluster and a capacity provider.

It creates the following resources

- aws_ecs_cluster
- aws_ecs_capacity_provider
- aws_ecs_cluster_capacity_providers

### Inputs

This module requires the following inputs:

| Variable          | Type   | Description                                                                                                                                |
| ----------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| name_prefix       | String | Prefix for tagging purposes                                                                                                                |
| region            | String | AWS region eg. us-west-2                                                                                                                   |
| vpc_id            | String | AWS resource ID for the VPC to associate the cluster with                                                                                  |
| asg_arn           | String | AWS resource ARN for the auto-scaling group to be used as the capacity provider                                                            |
| cluster_name      | String | The name for the ECS cluster                                                                                                               |
| ecs_provider      | String | The desired provider for the ECS cluster. Must be one of "EC2" or "FARGATE"                                                                |
| log_configuration | Object | See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster#log_configuration) for more information |
| kms_key_id        | String | AWS resource ID for a KMS key to be used for encrypting the data between local client and container                                        |

### Usage

To use this module, specify the source with the required inputs:

```terraform
module "my_ecs_cluster" {
  source             = "./ecs"
  name_prefix        = "test"
  region             = "ap-southeast-2"
  vpc_id             = "vpc-123"
  asg_arn            = "arn:..."
  cluster_name       = "testing"
}
```

### Outputs

Once the module has completed you can access the following:

| Variable     | Type   | Description                                      |
| ------------ | ------ | ------------------------------------------------ |
| cluster_name | String | AWS resource name of the provisioned ECS cluster |
| cluster_id   | String | AWS resource ID of the provisioned ECS cluster   |
| cluster_arn  | String | AWS resource ARN of the provisioned ECS cluster  |

This can be done by referencing the instance like so:

```terraform
module "sample" {
  source          = "./sample"
  input_variables = module.my_ecs_cluster.cluster_id
  ...
}
```
