resource "aws_security_group" "all-from-vpc" {
  name        = "allow-from-vpc"
  description = "Allow inbound from VPC"
  vpc_id      = data.aws_vpc.us.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                   = "allow-from-vpc"
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}