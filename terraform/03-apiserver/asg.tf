resource "aws_autoscaling_group" "kube-apiserver" {
  name                      = "kube-apiserver"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.apiserver-node.name
  vpc_zone_identifier       = "${tolist(data.aws_subnet_ids.subnet-kube.ids)}"

  tag {
    key                 = "kubernetes.io/cluster/cluster-mstakx"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/role/master"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes-type"
    value               = "apiserver"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "k8s-apiserver"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_attachment" "kube-apiserver" {
  autoscaling_group_name = "${aws_autoscaling_group.kube-apiserver.id}"
  elb                    = "${aws_elb.kube-apiserver.id}"
}