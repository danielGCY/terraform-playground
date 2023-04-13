# Module: asg

### Purpose

This module creates a generic autoscaling group. It supports defining mixed instance policies. To add lifecycle hooks, use `aws_autoscaling_lifecycle_hook` and reference the output `asg_id`. By default, the ASG uses `launch_templates` to launch instances, if `instance_distribution` is defined, the ASG will use [mixed instances policies](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_MixedInstancesPolicy.html).

It creates the following resources

- aws_placement_group
- aws_autoscaling_group

### Inputs

This module requires the following inputs:

| Variable                       | Type         | Description                                                                                                                                                                                                                                    |
| ------------------------------ | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name_prefix                    | String       | Prefix for tagging purposes                                                                                                                                                                                                                    |
| region                         | String       | AWS region eg. us-west-2                                                                                                                                                                                                                       |
| subnet_ids                     | List[String] | List of AWS resource ID for subnets to associate with the ASG                                                                                                                                                                                  |
| placement_strategy             | String       | One of "cluster", "partition", or "spread"                                                                                                                                                                                                     |
| max_size                       | Number       | The maximum number of instances for the ASG                                                                                                                                                                                                    |
| min_size                       | Number       | The minumum number of instances for the ASG                                                                                                                                                                                                    |
| desired_capacity               | Number       | The desired number of instances for the ASG                                                                                                                                                                                                    |
| target_group_arns              | String       | The ARN of the target group. To be used when fronting the ASG with an Application or Network Load Balancer                                                                                                                                     |
| health_check_grace_period      | Number       | The interval between health checks                                                                                                                                                                                                             |
| health_check_type              | String       | One of "EC2" or "ELB"                                                                                                                                                                                                                          |
| force_delete                   | Boolean      | Specify whether the ASG can be deleted before waiting for all instances in the pool to terminate                                                                                                                                               |
| launch_template_id             | String       | AWS resource ID of a launch template to be used with the ASG                                                                                                                                                                                   |
| service_linked_role_arn        | String       | AWS resource ARN of an IAM role that the ASG will use to call otehr AWS services                                                                                                                                                               |
| enabled_metrics                | List[String] | List of metrics specified [here](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_EnableMetricsCollection.html)                                                                                                                    |
| instance_distribution          | Object       | Settings on how to mix on-demand and Spot instances in ASG (See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#instances_distribution) for more information)                             |
| mixed_policies_launch_template | Object       | Settings on launch template settings along with overrides to be used in the ASG (See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#launch_template_specification) for more information) |
| ecs_managed                    | Boolean      | Specify whether or not the ASG will be linked to an ECS cluster                                                                                                                                                                                |
| additional_attachments         | Boolean      | Specify whether or not the ASG will have additional `aws_autoscaling_attachment` resource blocks associated with it                                                                                                                            |

### Usage

To use this module, specify the source with the required inputs:

```terraform
module "my_asg" {
  source             = "./asg"
  name_prefix        = "test"
  region             = "ap-southeast-2"
  subnet_ids         = ["subnet-123"]
  launch_template_id = [""]
}
```

### Outputs

Once the module has completed you can access the following:

| Variable           | Type   | Description                                           |
| ------------------ | ------ | ----------------------------------------------------- |
| placement_group_id | String | AWS resource ID of the provisioned placement_group    |
| asg_id             | String | AWS resource ID for the provisioned autoscaling_group |

This can be done by referencing the instance like so:

```terraform
module "sample" {
  source          = "./sample"
  input_variables = module.my_asg.asg_id
  ...
}
```
