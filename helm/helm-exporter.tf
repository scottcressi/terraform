resource "kubernetes_namespace" "helm-exporter" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "helm-exporter"
  }

  depends_on = [
    helm_release.prometheus-operator
  ]
}

resource "helm_release" "helm-exporter" {
  name       = "helm-exporter"
  repository = "https://shanestarcher.com/helm-charts/"
  chart      = "helm-exporter"
  version    = "0.6.0+61daf2c"
  namespace  = "helm-exporter"

  depends_on = [kubernetes_namespace.helm-exporter]

  values = [<<EOF
serviceMonitor:
  create: true
  namespace: monitoring
  additionalLabels:
    app: helm-helm-exporter
    release: prometheus-operator
replicaCount: 2
EOF
  ]

}
