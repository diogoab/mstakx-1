resource "aws_security_group" "apiserver" {
  name        = "apiserver"
  description = "Allow inbound traffic to API Server"
  vpc_id      = data.aws_vpc.us.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.cidr
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.cidr
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.cidr
  }

  ingress {
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    cidr_blocks = local.cidr
  }

  ingress {
    from_port   = 6783
    to_port     = 6784
    protocol    = "udp"
    cidr_blocks = local.cidr
  }

  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.elb-apiserver.id]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = local.cidr
  }


  ingress {
    from_port   = 10250
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = local.cidr
}

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb-apiserver" {
  name        = "elb-apiserver"
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
    from_port = "6443"
    to_port   = "6443"
    protocol  = "tcp"
    cidr_blocks = local.cidr
  }
}