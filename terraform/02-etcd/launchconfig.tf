data template_file userdata {
  template = "${file("userdata/cloud-config.yaml")}"
  vars = {
    zone-id = data.aws_route53_zone.k8s-mstakx.id
  }
}

resource "aws_launch_configuration" "etcd-node" {
  iam_instance_profile = aws_iam_instance_profile.kube-etcd-profile.name
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = "t3.small"
  spot_price           = "0.0100"
  ebs_optimized        = true
  key_name             = "kube-dns"

  security_groups = [aws_security_group.etcd.id]

  ebs_block_device {
      device_name = "sdf"
      volume_size = "10"
  }

  user_data = "${base64encode(data.template_file.userdata.rendered)}"

  lifecycle {
    create_before_destroy = true
  }
}