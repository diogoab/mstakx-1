
resource "aws_route53_record" "elb-etcd-k8s-mstakx" {
  zone_id = data.aws_route53_zone.k8s-mstakx.id
  name    = "etcd.k8s.mstakx"
  type    = "A"

  alias {
    name                   = aws_elb.kube-etcd.dns_name
    zone_id                = aws_elb.kube-etcd.zone_id
    evaluate_target_health = false
  }
}

