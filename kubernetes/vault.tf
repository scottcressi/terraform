resource "kubernetes_namespace" "vault" {
  count = var.environment == "shared" ? 1 : 0
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
  count      = var.environment == "shared" ? 1 : 0
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
        kms_key_id = "alias/vault-${var.environment}-${random_string.vault_alias.result}"
        region     = "us-east-1"
        access_key = "${aws_iam_access_key.vault.id}"
        secret_key = "${aws_iam_access_key.vault.secret}"
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

resource "aws_iam_access_key" "vault" {
  user = aws_iam_user.vault.name
}

resource "aws_iam_user" "vault" {
  name = "vault"
}

resource "aws_iam_user_policy" "vault" {
  name = "test"
  user = aws_iam_user.vault.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ],
    "Resource": "*"
  }
}
EOF
}

module "kms" {
  depends_on  = [helm_release.vault]
  source      = "Cloud-42/kms/aws"
  version     = "1.3.0"
  alias_name  = "vault-${var.environment}-${random_string.vault_alias.result}"
  description = "test"
}

resource "random_string" "vault_alias" {
  length  = 8
  special = false
  upper   = false
  number  = false
}
