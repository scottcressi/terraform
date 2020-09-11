resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "monitoring"
  }
}

resource "helm_release" "mariadb" {
  name       = "mariadb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mariadb"
  version    = "7.9.2"
  namespace  = "monitoring"

  depends_on = [kubernetes_namespace.monitoring]

  values = [
    "${file("prometheus-operator.yaml")}"
  ]

}

resource "helm_release" "prometheus-operator" {
  name       = "prometheus-operator"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "prometheus-operator"
  version    = "9.3.1"
  namespace  = "monitoring"

  depends_on = [kubernetes_namespace.monitoring]

  values = [
    "${file("prometheus-operator.yaml")}"
  ]

}
