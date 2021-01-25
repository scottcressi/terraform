resource "kubernetes_namespace" "kubernetes-dashboard" {
  depends_on = [
    module.my-cluster.cluster_id
  ]
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "kubernetes-dashboard"
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  version    = "2.3.0"
  namespace  = "kubernetes-dashboard"

  depends_on = [kubernetes_namespace.kubernetes-dashboard]

  values = [<<EOF
rbac:
  clusterReadOnlyRole: true
ingress:
  hosts:
    - kubernetes-dashboard-k8s.${var.environment}.${var.zone}.com
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: 'true'
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
  paths:
    - /
    - /*
replicaCount: 2
EOF
  ]

}
