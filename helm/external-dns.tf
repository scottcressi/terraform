resource "kubernetes_namespace" "external-dns" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "external-dns"
  }
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "3.3.0"
  namespace  = "external-dns"

  depends_on = [kubernetes_namespace.external-dns]

  values = [
    "${file("external-dns.yaml")}"
  ]

  set {
    name  = "aws.credentials.accessKey"
    value = var.accesskey
  }

  set {
    name  = "aws.credentials.secretKey"
    value = data.vault_generic_secret.external-dns-aws-credentials-secretkey.data["secret_key"]
  }

  set {
    name  = "domainFilters"
    value = "{${local.dns_zone_name}}"
  }

}

locals {
  dns_zone_name = "${var.environment}.${var.zone}.com"
}

data "vault_generic_secret" "external-dns-aws-credentials-secretkey" {
  path = "secret/helm/external-dns"
}

variable "accesskey" {
  type        = string
}
