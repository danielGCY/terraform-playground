# Module: application_deployment

### Purpose

This module creates the necessary resources to enable deployment of a dockerized application via ECS.

It creates the following resources

- aws_ecr_repository
- aws_ecs_cluster
- aws_ecs_capacity_provider
- aws_ecs_cluster_capacity_providers
- aws_ecs_task_definition
- aws_ecs_service

### Inputs

This module requires the following inputs:

| Variable                                 | Type         | Description                                                                                                                                                                                                                                                                          |
| ---------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| name_prefix                              | String       | Prefix for tagging purposes                                                                                                                                                                                                                                                          |
| region                                   | String       | AWS region eg. us-west-2                                                                                                                                                                                                                                                             |
| global_tags                              | Map[String]  | Tags to be applied to all the provisioned resources                                                                                                                                                                                                                                  |
| create_ecr                               | Boolean      | Whether to create an ECR. Defaults to `true`                                                                                                                                                                                                                                         |
| ecr_name                                 | String       | Name for the ECR. Defaults to `"${var.name_prefix}-ecr-main"`                                                                                                                                                                                                                        |
| ecr_tags                                 | Map[String]  | Tags to be applied to the ECR only                                                                                                                                                                                                                                                   |
| force_delete                             | Boolean      | Whether to enable deletion of ECR when there's images. Defaults to `false`                                                                                                                                                                                                           |
| vpc_id                                   | String       | AWS resource ID for the VPC to associate the cluster with                                                                                                                                                                                                                            |
| asg_arn                                  | String       | AWS resource ARN for the auto-scaling group to be used as the capacity provider                                                                                                                                                                                                      |
| ecs_cluster_name                         | String       | The name for the ECS cluster. Defaults to `"${var.name_prefix}-ecs-cluster-default"`                                                                                                                                                                                                 |
| ecs_provider                             | String       | The desired provider for the ECS cluster. Must be one of "EC2" or "FARGATE"                                                                                                                                                                                                          |
| ecs_cluster_log_configuration            | Object       | See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster#log_configuration) for more information                                                                                                                                           |
| ecs_cluster_kms_key_id                   | String       | AWS resource ID for a KMS key to be used for encrypting the data between local client and container                                                                                                                                                                                  |
| ecs_cluster_tags                         | Map[String]  | Tags to be applied to the ECS cluster only                                                                                                                                                                                                                                           |
| task_definition_family                   | String       | Name for the task definition. Defaults to `"${var.name_prefix}-app"`                                                                                                                                                                                                                 |
| reference_created_ecr                    | Boolean      | Specify whether the image to be deployed is contained in the ECR that will be provisioned. Note that if `image` property exists in a container definition, it will not be overwritten. Defaults to `true`                                                                            |
| image_tag                                | String       | The tag of the image to be referenced. Only used if `reference_created_ecr` is `true`. Defaults to "latest"                                                                                                                                                                          |
| task_definition_container_definitions    | String       | JSON string representation for the container definitions. See [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions) for more information                                                                         |
| task_definition_network_mode             | String       | Docker networking mode to use for the containers in the task. Must be one of "none", "bridge", "awsvpc", or "host". Defaults to "awsvpc"                                                                                                                                             |
| task_definition_cpu                      | Number       | Number of cpu units used by the task. Must be provided if `task_definition_required_capabilities` is "FARGATE"                                                                                                                                                                       |
| task_definition_memory                   | Number       | Amount of memory (MiB) used by the task. Must be provided if `task_definition_required_capabilities` is "FARGATE"                                                                                                                                                                    |
| task_definition_required_compatibilities | String       | Launch type required by the task. Must be one of "EC2" or "FARGATE". Defaults to "EC2"                                                                                                                                                                                               |
| task_definition_execution_role_arn       | String       | ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume                                                                                                                                                                                  |
| task_definition_ipc_mode                 | String       | IPC resource namespace to be used for the containers in the task. Must be one of "host", "task", or "none"                                                                                                                                                                           |
| task_definition_pid_mode                 | String       | Process namespace to use for the containers in the task. Must be either "host" or "task"                                                                                                                                                                                             |
| task_definition_skip_destroy             | String       | Whether to retain the old revision when the resource is destroyed or replacement is necessary. Defaults to `false`                                                                                                                                                                   |
| task_definition_task_role_arn            | String       | ARN of IAM role that allows ECS container task to make calls to other AWS services                                                                                                                                                                                                   |
| task_definition_volume                   | Object       | Configuration block for volumes that containers in the task may use. Currently only support configuration of `name` and `host_path`. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#volume) for more information         |
| task_definition_placement_constraints    | List[Object] | Placement constraint rules that are taken into consideration during task placement. Must only specify 10 or less constraints. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#placement_constraints) for more information |
| task_definition_tags                     | Map[String]  | Tags to be applied to the task definition only                                                                                                                                                                                                                                       |
| service_name                             | String       | Name for the ECS service. Defaults to `"${name_prefix}-ecs-service"`                                                                                                                                                                                                                 |
| service_alarms                           | Object       | Cloudwatch alarms for the ECS service. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#alarms) for more information                                                                                                               |
| desired_instance_count                   | Number       | Desired number of instances for the ECS service. Defaults to 1                                                                                                                                                                                                                       |
| enable_ecs_managed_tags                  | Boolean      | Specifies whether to enable Amazon ECS managed tags for the tasks within the service                                                                                                                                                                                                 |
| enable_execute_command                   | Boolean      | Specifies whether to enable Amazon ECS Exec fo rthe tasks within the service                                                                                                                                                                                                         |
| force_new_deployment                     | Boolean      | Enable to force a new taks deployment of the same service                                                                                                                                                                                                                            |
| health_check_grace_period_seconds        | Number       | Seconds to ignore failing load balancer health checks on newly instantiated tasks                                                                                                                                                                                                    |
| service_iam_role                         | String       | ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf. Only required when using a load balancer and your task definition does not use the `awsvpc` network mode                                                                              |
| service_launch_type                      | String       | Launch type on which to run the service. Must be one of "EC2", "FARGATE", or "EXTERNAL". Defaults to "EC2"                                                                                                                                                                           |
| service_load_balancer                    | Object       | Load balancer config. Specify `elb_name` if using a classic ELB, otherwise, use `target_group_arn`. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer) for more information                                           |
| service_network_configuration            | Object       | Network configuration for the service. Must be specified if `task_definition_network_mode` is "awsvpc". See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#network_configuration) for more information                               |
| service_ordered_placement_strategies     | List[Object] | Service level strategy rules that are taken into consideration during task placement. Must only specify at most 5 strategies. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#ordered_placement_strategy) for more information    |
| service_placement_constraints            | List[Object] | Placement constraint rules that are taken into consideration during task placement. Must only specify at most 10 constraints. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#placement_constraints) for more information         |
| service_platform_version                 | String       | Platform version to run the service. Only applicable for "FARGATE" `service_launch_type`. Defaults to "LATEST"                                                                                                                                                                       |
| service_propagate_tags                   | String       | Specifies whether to propogate the tags from the task definition or the service to the tasks. Must be either "SERVICE" or "TASK_DEFINITION"                                                                                                                                          |
| service_scheduling_strategy              | String       | Scheduling strategy to use for the service. Valid values are "REPLICA" and "DAEMON". Tasks using "FARGATE" launch type or "CODE_DEPLOY" or "EXTERNAL" deployment controller types don't support the "DAEMON" scheduling strategy                                                     |
| service_registries                       | Object       | Service discovery registries for the service. See [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#service_registries) for more information                                                                                            |
| service_triggers                         | Map[String]  | Map of arbitrary keys and values that, when changed, will trigger an in-place update (or redeployment)                                                                                                                                                                               |
| service_wait_for_steady_state            | Boolean      | If `true`, Terraform will wai for the service to reach a steady state before continuing. Defaults to `false`                                                                                                                                                                         |
| service_tags                             | Map[String]  | Tags to be applied to the ECS service only                                                                                                                                                                                                                                           |

### Usage

To use this module, specify the source with the required inputs:

```terraform
module "my_ecs_cluster" {
  source             = "./ecs"
  name_prefix        = "test"
  region             = "ap-southeast-2"
  vpc_id             = "vpc-123"
  asg_arn            = "arn:..."
  task_definition_container_definitions = jsonencode([{...}])
}
```

### Outputs

Once the module has completed you can access the following:

| Variable           | Type   | Description                                        |
| ------------------ | ------ | -------------------------------------------------- |
| ecr_repository_url | String | URL of the provisioned ECR repository              |
| ecr_repository_id  | String | AWS resource ID of the provisioned ECR repository  |
| ecr_repository_arn | String | AWS resource ARN of the provisioned ECR repository |
| cluster_name       | String | AWS resource name of the provisioned ECS cluster   |
| cluster_id         | String | AWS resource ID of the provisioned ECS cluster     |
| cluster_arn        | String | AWS resource ARN of the provisioned ECS cluster    |

This can be done by referencing the instance like so:

```terraform
module "sample" {
  source          = "./sample"
  input_variables = module.my_ecs_cluster.cluster_id
  ...
}
```
