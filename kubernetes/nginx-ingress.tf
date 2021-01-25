resource "kubernetes_namespace" "ingress-nginx" {
  depends_on = [
    module.my-cluster.cluster_id
  ]
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
  depends_on = [
    module.my-cluster.cluster_id
  ]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "3.5.1"
  namespace  = "ingress-nginx"

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
