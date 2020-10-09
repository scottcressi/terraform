resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "3.5.1"
  namespace  = "ingress-nginx"

  depends_on = [
    kubernetes_namespace.ingress-nginx,
    helm_release.prometheus-operator,
  ]

  values = [<<EOF
controller:
  config:
    use-forwarded-headers: "true"
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
      additionalLabels:
        app: ingress-nginx
        release: prometheus-operator
      namespace: monitoring
  stats:
    enabled: true
  kind: DaemonSet
  publishService:
    enabled: true
  service:
    targetPorts:
      https: 80
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert:
        ${aws_acm_certificate_validation.example.certificate_arn}
EOF
  ]

}

resource "aws_acm_certificate" "example" {
  domain_name       = "*.${var.zone}.com"
  validation_method = "DNS"
}

data "aws_route53_zone" "example" {
  name         = "${var.zone}.com"
  private_zone = false
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.example.zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}
