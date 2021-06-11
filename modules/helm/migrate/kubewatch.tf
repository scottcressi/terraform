resource "kubernetes_namespace" "kubewatch" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "kubewatch"
  }
}

resource "helm_release" "kubewatch" {
  name       = "kubewatch"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kubewatch"
  version    = "1.2.3"
  namespace  = "kubewatch"

  depends_on = [kubernetes_namespace.kubewatch]

  values = [<<EOF
resourcesToWatch:
  deployment: true
  pod: false
replicaCount: 2
slack:
  channel: "#kubewatch-${var.environment}"
  token: SOMESECRET
EOF
  ]

}
