resource "kubernetes_namespace" "docker-registry-ui" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "docker-registry-ui"
  }
}

resource "helm_release" "docker-registry-ui" {
  name      = "docker-registry-ui"
  chart     = "/var/tmp/docker-registry-ui/examples/helm/docker-registry-ui"
  namespace = "docker-registry-ui"

  depends_on = [kubernetes_namespace.docker-registry-ui]

  values = [<<EOF
registry:
  external: true
  url: http://docker-registry.docker-registry:5000
ui:
  delete_images: true
  replicaCount: 2
  ingress:
    hosts:
      - host: docker-registry-ui-k8s.${var.environment}.${var.zone}.com
    enabled: false
    annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
EOF
  ]

}
