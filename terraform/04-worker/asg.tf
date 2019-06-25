resource "aws_autoscaling_group" "kube-worker" {
  name                      = "kube-worker"
  max_size                  = 3
  min_size                  = 3
  health_check_grace_period = 300
  desired_capacity          = 3
  force_delete              = true
  launch_configuration      = aws_launch_configuration.worker-node.name
  vpc_zone_identifier       = "${tolist(data.aws_subnet_ids.subnet-kube.ids)}"

  tag {
    key                 = "kubernetes.io/cluster/cluster-mstakx"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes-type"
    value               = "worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "k8s-worker"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}
