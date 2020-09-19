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
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "node-problem-detector"
  version    = "1.7.6"
  namespace  = "node-problem-detector"

  depends_on = [
                kubernetes_namespace.node-problem-detector,
                helm_release.prometheus-operator,
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
