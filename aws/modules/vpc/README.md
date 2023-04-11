# Module: vpc

### Purpose

This module creates a generic VPC. It supports creation of public and private subnets (up to the number of AZs available to the specified region). Currently, it only allows creation of an internet gateway (associated with public subnets) and a NAT gateway (associated with private subnets).

It creates the following resources

- aws_vpc
- aws_subnet
- aws_internet_gateway
- aws_route_table (one for each of public and private subnets)
- aws_route_table_association (one for each of public and private subnets)
- aws_eip
- aws_nat_gateway

### Inputs

This module requires the following inputs:

| Variable                   | Type         | Description                                              |
| -------------------------- | ------------ | -------------------------------------------------------- |
| name_prefix                | String       | Prefix for tagging purposes                              |
| region                     | String       | AWS region eg. us-west-2                                 |
| cidr_block                 | String       | IP range for the entire network eg. 192.168.0.0/24       |
| enable_dns_hostnames       | Bool         | True/False if you want to enable hostnames               |
| public_subnet_cidr_blocks  | List[String] | List of CIDR blocks corresponding to the public subnets  |
| private_subnet_cidr_blocks | List[String] | List of CIDR blocks corresponding to the private subnets |

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

| Variable                       | Type         | Description                                                                                    |
| ------------------------------ | ------------ | ---------------------------------------------------------------------------------------------- |
| vpc_id                         | String       | AWS Resource id for the VPC eg. vpc-1234                                                       |
| vpc_cidr_block                 | String       | CIDR block for provisioned VPC eg. 10.0.0.0/16                                                 |
| availability_zones             | List[String] | List of availability zones for the specified region eg. ["ap-southeast-2a", "ap-southeast-2b"] |
| internet_gateway_id            | String       | AWS Resource id for the provisioned internet gateway                                           |
| public_subnets_ids             | String       | List of AWS resource ids eg. ["subnet-1", "subnet-2"]                                          |
| public_subnets_route_table_id  | String       | AWS Resource id for the provisioned route table associated with public subnets                 |
| nat_gateway_id                 | String       | AWS Resource id for the provisioned NAT gateway for private subnets                            |
| private_subnets_ids            | Bool         | List of AWS resource ids eg. ["subnet-3", "subnet-4"]                                          |
| private_subnets_route_table_id | String       | AWS Resource id for the provisioned route table associated with private subnets                |

This can be done by referencing the instance like so:

```terraform
module "sample" {
  source          = "./sample"
  input_variables = module.my-vpc.vpc_id
  ...
}
```
