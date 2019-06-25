resource "aws_security_group" "etcd" {
  name        = "etcd"
  description = "Allow inbound traffic to Etcd Server"
  vpc_id      = data.aws_vpc.us.id

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = local.cidr
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.cidr
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb-etcd" {
  name        = "elb-etcd"
  vpc_id      = data.aws_vpc.us.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port = "2379"
    to_port   = "2380"
    protocol  = "tcp"

    cidr_blocks = local.cidr
  }
}