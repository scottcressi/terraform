resource "kubernetes_namespace" "kubernetes-dashboard" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "kubernetes-dashboard"
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  version    = "2.3.0"
  namespace  = "kubernetes-dashboard"

  depends_on = [kubernetes_namespace.kubernetes-dashboard]

  values = [
    "${file("kubernetes-dashboard.yaml")}"
  ]

  set {
    name  = "ingress.hosts"
    value = "{${local.kubernetes-dashboard-hosts}}"
  }

}

locals {
  kubernetes-dashboard-hosts = "kubernetes-dashboard-k8s.${var.environment}.${var.zone}.com"
}
