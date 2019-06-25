
resource "aws_route53_record" "elb-apiserver-k8s-mstakx" {
  zone_id = data.aws_route53_zone.k8s-mstakx.id
  name    = "apiserver.k8s.mstakx"
  type    = "A"

  alias {
    name                   = aws_elb.kube-apiserver.dns_name
    zone_id                = aws_elb.kube-apiserver.zone_id
    evaluate_target_health = false
  }
}