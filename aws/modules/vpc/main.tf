terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "default" {
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = min(length(var.public_subnet_cidr_blocks), length(data.aws_availability_zones.default.id))

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.default.names[count.index]

  tags = {
    Name = "${var.name_prefix}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = min(length(var.private_subnet_cidr_blocks), length(data.aws_availability_zones.default.id))

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.default.names[count.index]

  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_gateway_ip" {
  vpc = true
}

resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnet_cidr_blocks) >= 1 ? 1 : 0
  subnet_id     = aws_subnet.private[0].id
  allocation_id = aws_eip.nat_gateway_ip.id

  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidr_blocks) >= 1 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  depends_on = [aws_nat_gateway.main]

  tags = {
    Name = "${var.name_prefix}-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
