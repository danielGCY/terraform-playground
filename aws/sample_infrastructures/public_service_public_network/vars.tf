variable "name_prefix" {
  description = "The prefix for the names of the resources to be provisioned"
  default     = "public-service-public-network"
}

variable "region" {
  default = "ap-southeast-2"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_port" {
  description = "The port that the containerized app is served on."
}
