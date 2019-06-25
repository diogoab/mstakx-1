resource "aws_autoscaling_group" "kube-etcd" {
  name                      = "kube-etcd"
  max_size                  = 3
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  launch_configuration      = aws_launch_configuration.etcd-node.name
  vpc_zone_identifier       = "${tolist(data.aws_subnet_ids.subnet-kube.ids)}"

  tag {
    key                 = "kubernetes.io/cluster/cluster-mstakx"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes-type"
    value               = "etcd"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "k8s-etcd"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_attachment" "kube-etcd" {
  autoscaling_group_name = "${aws_autoscaling_group.kube-etcd.id}"
  elb                    = "${aws_elb.kube-etcd.id}"
}