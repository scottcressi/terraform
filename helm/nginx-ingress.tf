resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "nginx-ingress"
  version    = "1.41.3"
  namespace  = "nginx-ingress"

  depends_on = [
                kubernetes_namespace.nginx-ingress,
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
        app: nginx-ingress
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
        ${var.nginx-ingress-certarn["${var.environment}"]}
EOF
  ]

}
