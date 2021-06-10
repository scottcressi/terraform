resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.6.8"
  namespace  = "argocd"
  create_namespace = true
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
