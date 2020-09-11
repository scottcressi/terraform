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

  values = [
    "${file("kubewatch.yaml")}"
  ]

  set {
    name  = "slack.channel"
    value = "kubewatch-${var.environment}"
  }

  set {
    name  = "slack.token"
    value = data.vault_generic_secret.slack-token.data["slack_token"]
  }

}

data "vault_generic_secret" "slack-token" {
  path = "secret/helm/kubewatch"
}
