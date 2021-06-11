resource "kubernetes_namespace" "chartmuseum" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "chartmuseum"
  }
}

resource "helm_release" "chartmuseum" {
  name       = "chartmuseum"
  repository = "https://chartmuseum.github.io/charts"
  chart      = "chartmuseum"
  version    = "2.14.2"
  namespace  = "chartmuseum"

  depends_on = [kubernetes_namespace.chartmuseum]

  values = [<<EOF
env:
  open:
    DISABLE_API: false
  secret:
    BASIC_AUTH_USER: admin
    BASIC_AUTH_PASS: ${random_password.chartmuseum-BASIC_AUTH_PASS.result}
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
  hosts:
    - name: chartmuseum-k8s.${var.environment}.${var.zone}.com
persistence:
  enabled: true
EOF
  ]

}

resource "random_password" "chartmuseum-BASIC_AUTH_PASS" {
  length           = 16
  special          = true
  override_special = "_%@"
}
