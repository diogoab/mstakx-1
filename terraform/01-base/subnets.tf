resource "aws_subnet" "subnet-kube-private-1a" {
  vpc_id            = data.aws_vpc.us.id
  availability_zone = "us-east-1a"
  cidr_block        = module.vpc-data.cidr-private-1

  tags = {
    Name                                   = "subnet-kube-private-1a"
    Type                                   = "k8s-private"
    "kubernetes.io/role/internal-elb"      = true
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}

resource "aws_subnet" "subnet-kube-private-1c" {
  vpc_id            = data.aws_vpc.us.id
  availability_zone = "us-east-1c"
  cidr_block        = module.vpc-data.cidr-private-2

  tags = {
    Name                                   = "subnet-kube-private-1c"
    Type                                   = "k8s-private"
    "kubernetes.io/role/internal-elb"      = true
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}

resource "aws_subnet" "subnet-kube-private-1f" {
  vpc_id            = data.aws_vpc.us.id
  availability_zone = "us-east-1f"
  cidr_block        = module.vpc-data.cidr-private-3

  tags = {
    Name                                   = "subnet-kube-private-1f"
    Type                                   = "k8s-private"
    "kubernetes.io/role/internal-elb"      = true
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}

resource "aws_route_table_association" "kube-private-1a" {
  subnet_id      = aws_subnet.subnet-kube-private-1a.id
  route_table_id = data.aws_route_table.nat.id
}

resource "aws_route_table_association" "kube-private-1c" {
  subnet_id      = aws_subnet.subnet-kube-private-1c.id
  route_table_id = data.aws_route_table.nat.id
}

resource "aws_route_table_association" "kube-private-1f" {
  subnet_id      = aws_subnet.subnet-kube-private-1f.id
  route_table_id = data.aws_route_table.nat.id
}


resource "aws_subnet" "subnet-kube-1a" {
  vpc_id            = data.aws_vpc.us.id
  availability_zone = "us-east-1a"
  cidr_block        = module.vpc-data.cidr-1

  map_public_ip_on_launch = true

  tags = {
    Name                                   = "subnet-kube-1a"
    Type                                   = "k8s-public"
    "kubernetes.io/role/elb"               = true
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}

resource "aws_subnet" "subnet-kube-1c" {
  vpc_id            = data.aws_vpc.us.id
  availability_zone = "us-east-1c"
  cidr_block        = module.vpc-data.cidr-2

  map_public_ip_on_launch = true

  tags = {
    Name                                   = "subnet-kube-1c"
    Type                                   = "k8s-public"
    "kubernetes.io/role/elb"               = true 
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}

resource "aws_subnet" "subnet-kube-1f" {
  vpc_id            = data.aws_vpc.us.id
  availability_zone = "us-east-1f"
  cidr_block        = module.vpc-data.cidr-3

  map_public_ip_on_launch = true

  tags = {
    Name                                   = "subnet-kube-1f"
    Type                                   = "k8s-public"
    "kubernetes.io/role/elb"               = true
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}

resource "aws_route_table_association" "kube-1a" {
  subnet_id      = aws_subnet.subnet-kube-1a.id
  route_table_id = data.aws_route_table.default.id
}

resource "aws_route_table_association" "kube-1c" {
  subnet_id      = aws_subnet.subnet-kube-1c.id
  route_table_id = data.aws_route_table.default.id
}

resource "aws_route_table_association" "kube-1f" {
  subnet_id      = aws_subnet.subnet-kube-1f.id
  route_table_id = data.aws_route_table.default.id
}

