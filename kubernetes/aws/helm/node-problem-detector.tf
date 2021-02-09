resource "kubernetes_namespace" "node-problem-detector" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "node-problem-detector"
  }
}

resource "helm_release" "node-problem-detector" {
  name       = "node-problem-detector"
  repository = "https://charts.deliveryhero.io/"
  chart      = "node-problem-detector"
  version    = "1.8.6"
  namespace  = "node-problem-detector"

  depends_on = [
    kubernetes_namespace.node-problem-detector,
  ]

  values = [<<EOF
metrics:
  serviceMonitor:
    enabled: true
    additionalLabels:
      app: helm-helm-exporter
      release: prometheus-operator
EOF
  ]

}
