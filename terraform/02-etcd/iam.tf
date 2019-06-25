data "template_file" "data-route53-policy" {
  template = "${file("iam/route53-policy.json")}"
  vars = {
    zone-id = data.aws_route53_zone.k8s-mstakx.id
  }
}

resource "aws_iam_policy" "route53-policy" {
  name   = "route53-policy"
  policy = data.template_file.data-route53-policy.rendered
}

resource "aws_iam_policy" "s3-policy" {
  name   = "s3-policy"
  policy = "${file("iam/s3-policy.json")}"
}

resource "aws_iam_policy" "asg-etcd-policy" {
  name   = "asg-etcd-policy"
  policy = "${file("iam/asg-policy.json")}"
}

resource "aws_iam_role" "kube-etcd" {
  name = "kube-etcd"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
   "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
       },
       "Effect": "Allow",
       "Sid": ""
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kube-nodes-attach-1" {
  role = aws_iam_role.kube-etcd.name
  policy_arn = aws_iam_policy.route53-policy.arn
}

resource "aws_iam_role_policy_attachment" "kube-nodes-attach-2" {
  role = aws_iam_role.kube-etcd.name
  policy_arn = aws_iam_policy.s3-policy.arn
}

resource "aws_iam_role_policy_attachment" "kube-nodes-attach-3" {
  role = aws_iam_role.kube-etcd.name
  policy_arn = aws_iam_policy.asg-etcd-policy.arn
}

resource "aws_iam_instance_profile" "kube-etcd-profile" {
  name = "kube-etcd-profile"
  role = aws_iam_role.kube-etcd.name
}