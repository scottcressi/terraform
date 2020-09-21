resource "kubernetes_namespace" "istio-system" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "istio-system"
  }
}

resource "helm_release" "istio-init" {
  name       = "istio-init"
  repository = "https://storage.googleapis.com/istio-release/releases/1.5.8/charts/"
  chart      = "istio-init"
  version    = "1.5.8"
  namespace  = "istio-system"

  depends_on = [kubernetes_namespace.istio-system]

}

resource "helm_release" "istio" {
  name       = "istio"
  repository = "https://storage.googleapis.com/istio-release/releases/1.5.8/charts/"
  chart      = "istio"
  version    = "1.5.8"
  namespace  = "istio-system"

  depends_on = [kubernetes_namespace.istio-system, helm_release.istio-init]

  values = [<<EOF
grafana:
  enabled: true
  ingress:
    enabled: true
    hosts:
      - istio-k8s.${var.environment}.${var.zone}.com
    annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: custom-nginx-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
tracing:
  enabled: true
  ingress:
    enabled: true
    hosts:
      - istio-k8s.${var.environment}.${var.zone}.com
    annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: custom-nginx-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
kiali:
  enabled: true
  dashboard:
    auth:
      strategy: anonymous
  ingress:
    enabled: true
    hosts:
      - istio-k8s.${var.environment}.${var.zone}.com
    annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: custom-nginx-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
prometheus:
  ingress:
    enabled: true
    hosts:
      - istio-k8s.${var.environment}.${var.zone}.com
    annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: custom-nginx-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
EOF
  ]

}
