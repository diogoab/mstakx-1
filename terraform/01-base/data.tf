
module vpc-data {
  source = "../module"
}

data "aws_vpc" "us" {
  id = module.vpc-data.vpc-id
}

data "aws_route_table" "nat" {
  route_table_id = module.vpc-data.nat-route-table-id
}

data "aws_route_table" "default" {
  route_table_id = module.vpc-data.route-table-id
}