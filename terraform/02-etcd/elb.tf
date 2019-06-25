resource "aws_elb" "kube-etcd" {
  name    = "elb-kube-etcd"
  subnets = "${tolist(data.aws_subnet_ids.subnet-kube.ids)}"

  security_groups = [aws_security_group.etcd.id, aws_security_group.elb-etcd.id]

  internal = true

  listener {
    instance_port     = "2379"
    instance_protocol = "TCP"
    lb_port           = "2379"
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = "2380"
    instance_protocol = "TCP"
    lb_port           = "2380"
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:2379"
    interval            = 6
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 900
  connection_draining         = true
  connection_draining_timeout = 30

  tags = {
    Name                                   = "elb-kube-etcd"
    kubernetes-type                        = "etcd"
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}