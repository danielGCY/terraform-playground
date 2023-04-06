# Module: vpc

### Inputs
This module requires the following inputs:

| Variable                   | Type         | Description                                        |
|----------------------------|--------------|----------------------------------------------------|
| region                     | String       | AWS region eg. us-west-2                           |
| cidr_block                 | String       | IP range for the entire network eg. 192.168.0.0/24 |
| enable_dns_hostnames       | Bool         | True/False if you want to enable hostnames         |
| public_subnet_cidr_blocks  | List[String] |                                                    |
| private_subnet_cidr_blocks | List[String] |                                                    |

### Usage

To use this module, specify the source with the required inputs:
```terraform
module "my-vpc" {
  source               = "./vpc"
  region               = "ap-southeast-2"
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
}
```

### Outputs

Once the module has completed you can access the following:

| Variable            | Type         | Description                                           |
|---------------------|--------------|-------------------------------------------------------|
| vpc_id              | String       | AWS Resource id for the VPC eg. vpc-1234              |
| public_subnets_ids  | String       | List of AWS resource ids eg. ["subnet-1", "subnet-2"] |
| private_subnets_ids | Bool         | List of AWS resource ids eg. ["subnet-3", "subnet-4"] |

This can be done by referencing the instance like so:
```terraform
module "sample" {
  source          = "./sample"
  input_variables = module.my-vpc.vpc_id
  ...
}
```
