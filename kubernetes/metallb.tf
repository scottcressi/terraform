resource "kubernetes_namespace" "metallb" {
  count      = var.location == "local" ? 1 : 0
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
  count      = var.location == "local" ? 1 : 0
  name       = "metallb"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metallb"
  version    = "0.12.1"
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
