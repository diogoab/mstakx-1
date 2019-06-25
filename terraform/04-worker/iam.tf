
resource "aws_iam_policy" "s3-policy" {
  name   = "s3-worker-policy"
  policy = "${file("iam/s3-policy.json")}"
}

resource "aws_iam_policy" "kube-worker-policy" {
  name   = "kube-worker-policy"
  policy = "${file("iam/asg-policy.json")}"
}

resource "aws_iam_policy" "route53-worker-policy" {
  name   = "route53-worker-policy"
  policy = "${file("iam/external-dns.json")}"
}

resource "aws_iam_role" "kube-worker" {
  name = "kube-worker"

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
  role = aws_iam_role.kube-worker.name
  policy_arn = aws_iam_policy.s3-policy.arn
}

resource "aws_iam_role_policy_attachment" "kube-nodes-attach-2" {
  role = aws_iam_role.kube-worker.name
  policy_arn = aws_iam_policy.kube-worker-policy.arn
}

resource "aws_iam_role_policy_attachment" "kube-nodes-attach-3" {
  role = aws_iam_role.kube-worker.name
  policy_arn = aws_iam_policy.route53-worker-policy.arn
}

resource "aws_iam_instance_profile" "kube-worker-profile" {
  name = "kube-worker-profile"
  role = aws_iam_role.kube-worker.name
}