resource "kubernetes_namespace" "vault" {
  count      = var.environment != "local" ? 1 : 0
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "vault"
  }
}

resource "helm_release" "vault" {
  count      = var.environment != "local" ? 1 : 0
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.7.0"
  namespace  = "vault"

  depends_on = [kubernetes_namespace.vault]

  values = [<<EOF
server:
  ha:
    enabled: true
    config: |
      ui = true
      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "consul" {
        path = "vault"
        address = "HOST_IP:8500"
      }
      seal "awskms" {
        kms_key_id = "alias/vault-${var.environment}"
        region     = "us-east-1"
        access_key = "${var.vault_accesskey}"
        secret_key = "${var.vault_secretkey}"
      }
  ingress:
    hosts:
      - host: vault-k8s.${var.environment}.${var.zone}.com
        paths:
          - /
    enabled: true
    annotations:
      |
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
ui:
  enabled: true
EOF
  ]

}

variable "vault_accesskey" {
  type        = string
}

variable "vault_secretkey" {
  type        = string
}
