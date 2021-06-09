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
  version    = "3.6.8"
  namespace  = kubernetes_namespace.argocd.id
  values = [<<EOF
server:
  config:
    application.instanceLabelKey: argocd.argoproj.io/instance
    repositories: |
      - sshPrivateKeySecret:
          key: sshPrivateKey
          name: github
        url: git@github.com:scottcressi/helm

controller:
  args:
    appResyncPeriod: "60"
EOF
  ]

}
