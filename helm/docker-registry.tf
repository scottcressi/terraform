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
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "docker-registry"
  version    = "1.9.4"
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
  secrets:
    htpasswd: ${var.docker_registry_htpasswd}
    haSharedSecret: ${data.vault_generic_secret.docker-registry-secrets.data["haSharedSecret"]}
replicaCount: 1 # this must stay 1
EOF
  ]

}

data "vault_generic_secret" "docker-registry-secrets" {
  path = "secret/helm/docker-registry"
}

variable "docker_registry_htpasswd" {
  type        = string
}
