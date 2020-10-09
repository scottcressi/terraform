resource "kubernetes_namespace" "metallb" {
  count = var.environment == "local" ? 1 : 0
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "metallb"
  }
}

resource "helm_release" "metallb" {
  count      = var.environment == "local" ? 1 : 0
  name       = "metallb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"
  version    = "0.1.24"
  namespace  = "metallb"

  depends_on = [kubernetes_namespace.metallb]

  values = [<<EOF
configInline:
  address-pools:
  - name: default
    protocol: layer2
    addresses:
    - 192.168.1.118-192.168.1.120
EOF
  ]

}
