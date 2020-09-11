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

  values = [<<EOF
rbac:
  create: true
publishInternalServices: true
domainFilters: ["${var.environment}.${var.zone}.com"]
replicas: 2
metrics:
  enabled: true
aws:
  credentials:
    accessKey: ${var.accesskey}
    secretKey: ${data.vault_generic_secret.external-dns-aws-credentials-secretkey.data["secret_key"]}
EOF
  ]

}

data "vault_generic_secret" "external-dns-aws-credentials-secretkey" {
  path = "secret/helm/external-dns"
}

variable "accesskey" {
  type        = string
}
