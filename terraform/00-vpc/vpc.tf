resource "aws_vpc" "k8s-mstakx" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "k8s-mstakx"
  }
}

resource "aws_subnet" "subnet-main-1c" {
  vpc_id            = aws_vpc.k8s-mstakx.id
  availability_zone = "us-east-1c"
  cidr_block        = "172.31.0.0/20"

  map_public_ip_on_launch = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw-k8s-mstakx" {
  vpc_id = aws_vpc.k8s-mstakx.id

  tags = {
    Name = "gw-k8s-mstakx"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw-nat-k8s-mstakx" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet-main-1c.id

  tags = {
    Name = "gw-nat-k8s-mstakx"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.k8s-mstakx.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-k8s-mstakx.id
  }

  tags = {
    Name = "main-route-table"
  }
}

resource "aws_main_route_table_association" "route-main" {
  vpc_id = aws_vpc.k8s-mstakx.id
  route_table_id = aws_route_table.route.id
}


resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.k8s-mstakx.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw-nat-k8s-mstakx.id
  }

  tags = {
    Name = "nat-route-table"
  }
}

