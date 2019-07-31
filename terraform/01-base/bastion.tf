data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "kube-dns"
  vpc_security_group_ids =  ["${aws_security_group.bastion.id}"]
  subnet_id              = "${aws_subnet.subnet-kube-1a.id}"
  iam_instance_profile   = "${aws_iam_instance_profile.bastion-profile.name}"

  tags = {
    Name = "bastion"
  }
}

output "bastion_ip" {
  value = ["${aws_instance.bastion.public_ip}"]
}
