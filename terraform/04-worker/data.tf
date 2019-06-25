module vpc-data {
  source = "../module"
}

data "aws_vpc" "us" {
  id = module.vpc-data.vpc-id
}

data "aws_route53_zone" "k8s-mstakx" {
  name         = "k8s.mstakx."
  private_zone = true
}

data "aws_subnet_ids" "subnet-kube" {
  vpc_id = data.aws_vpc.us.id

  tags = {
    "kubernetes.io/cluster/cluster-mstakx" = true
    Type              = "k8s-private"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

