variable "region" {
  default = "ap-southeast-2"
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  default = true
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the public subnets"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for the private subnets"
  default     = []
}
