resource "aws_elb" "kube-apiserver" {
  name    = "elb-kube-apiserver"
  subnets = "${tolist(data.aws_subnet_ids.subnet-kube.ids)}"

  security_groups = [aws_security_group.apiserver.id, aws_security_group.elb-apiserver.id]

  internal = true

  listener {
    instance_port     = "6443"
    instance_protocol = "TCP"
    lb_port           = "6443"
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:6443"
    interval            = 6
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 900
  connection_draining         = true
  connection_draining_timeout = 30

  tags = {
    Name                                   = "elb-kube-apiserver"
    kubernetes-type                        = "apiserver"
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}