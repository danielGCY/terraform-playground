output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "availability_zones" {
  value = data.aws_availability_zones.default.names
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}

output "public_subnets_ids" {
  value = aws_subnet.public.*.id
}

output "public_subnets_route_table_id" {
  value = aws_route_table.public.id
}

output "nat_gateway_id" {
  value = length(aws_nat_gateway.main) > 0 ? aws_nat_gateway.main[0].id : null
}

output "private_subnets_ids" {
  value = aws_subnet.private.*.id
}

output "private_subnets_route_table_id" {
  value = length(aws_route_table.private) > 0 ? aws_route_table.private[0].id : null
}
