resource "kubernetes_namespace" "docker-registry" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "docker-registry"
  }
}

resource "helm_release" "docker-registry" {
  name       = "docker-registry"
  repository = "https://helm.twun.io"
  chart      = "docker-registry"
  version    = "1.10.0"
  namespace  = "docker-registry"

  depends_on = [kubernetes_namespace.docker-registry]


  values = [<<EOF
ingress:
  hosts:
    - docker-registry-k8s.${var.environment}.${var.zone}.com
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
    nginx.ingress.kubernetes.io/proxy-body-size: 500m
  path: /
persistence:
  enabled: true
  deleteEnabled: true
replicaCount: 1 # this must stay 1
EOF
  ]

}
