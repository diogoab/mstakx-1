resource "aws_route53_zone" "private-k8s-mstakx" {
  name = "k8s.mstakx"

  vpc {
    vpc_id = data.aws_vpc.us.id
  }
}

resource "aws_route53_zone" "external-k8s-mstakx" {
  name = "external.mstakx"
 
  tags = {
    Name                                   = "external-dns"
    kubernetes-type                        = "external-dns"
    "kubernetes.io/cluster/cluster-mstakx" = true
  }
}
