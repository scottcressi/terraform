resource "kubernetes_namespace" "prometheus-consul-exporter" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "prometheus-consul-exporter"
  }
}

resource "helm_release" "prometheus-consul-exporter" {
  name       = "prometheus-consul-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-consul-exporter"
  version    = "0.2.0"
  namespace  = "prometheus-consul-exporter"

  depends_on = [kubernetes_namespace.prometheus-consul-exporter]

  values = [<<EOF
consulServer: consul-consul-server.consul:8500
EOF
  ]

}
