resource "aws_launch_configuration" "apiserver-node" {
  iam_instance_profile = aws_iam_instance_profile.kube-apiserver-profile.name
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = "t3.small"
  spot_price           = "0.0100"
  ebs_optimized        = true
  key_name             = "kube-dns"

  security_groups = [aws_security_group.apiserver.id]

  ebs_block_device {
      device_name = "sdf"
      volume_size = "10"
  }

  user_data = "${base64encode(file("userdata/cloud-config.yaml"))}"

  lifecycle {
    create_before_destroy = true
  }
}