resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "1.8.4"
  namespace  = "default"

  depends_on = [kubernetes_namespace.argocd]
  values = [<<EOF
EOF
  ]

}
