# Sample Infrastructure 1: Public Service Public Network

### Purpose

This folder contains Terraform code that creates the infrastructure described [here](https://containersonaws.com/architecture/public-service-public-network/). See the [cloudformation reference file](./cloudformation_reference.yml) for more information.

### Usage Guide

1. Run `terraform init`
2. Authenticate to AWS cli by following the instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
3. Duplicate the `input.tfvars.example` file and rename the new file to `input.tfvars`
4. Update the values for the variables in `input.tfvars` to suit your needs. See `[vars.tf](./vars.tf)` for more information on the variables.
5. Run `terraform apply --var-file="./input.tfvars" --auto-approve`
6. Once apply is completed, take note of the `load_balancer_ip` and navigate to the [AWS console](https://aws.amazon.com/console/) and navigate to ECR
7. Find and click into the repository named `${name_prefix}-main`, where `name_prefix` is the value you provided in `input.tfvars`. By default, the repository will be named "public-service-public-network-main".
8. Click on "View push commnads" and follow the prompts.
   > If you do not have your own app to deploy,
   >
   > - Navigate to `../../../common/test-app/`
   > - Run steps 2 - 4
9. Open a web browser of choice and navigate to `http://${load_balancer_ip}` where `load_balancer_ip` is the output from `terraform apply`
10. If everything worked correctly, you should see your app deployed and running
11. Once you are done, run `terraform destroy --var-file="./input.tfvars"` to destroy the provisioned resources

### Troubleshooting tips

**App not showing up**

1. Make sure that the specified `app_port` in "input.tfvars" is the expected port for the app you are deploying

### TODO

1. See if I can group the ECS stuff into a module
2. See if I can use locals to set all the constants and config used (think of it as a "constants" file)
3. Can think about moving the `terraform` and `provider` blocks into another folder (e.g. `providers.tf`)
4. A lot of hardcoded stuff may want to be configurable, or at least make it more obvious
5. Security group module
6. Think about how much data sharing happens between the various modules/resource blocks to see if I can separate or combine resource blocks together
7. Automate build and deploy of image
