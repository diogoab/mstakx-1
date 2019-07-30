
resource "aws_iam_policy" "s3-policy" {
  name   = "s3-bastion-policy"
  policy = "${file("iam/s3-policy.json")}"
}

resource "aws_iam_role" "bastion" {
  name = "bastion"

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

resource "aws_iam_role_policy_attachment" "bastion-attach-1" {
  role = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.s3-policy.arn
}

resource "aws_iam_instance_profile" "bastion-profile" {
  name = "bastion-profile"
  role = aws_iam_role.bastion.name
}