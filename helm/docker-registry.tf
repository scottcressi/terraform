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

  values = [
    "${file("docker-registry.yaml")}"
  ]

  set {
    name  = "ingress.hosts"
    value = "{${local.docker-registry-hosts}}"
  }

  set {
    name  = "secrets.htpasswd"
    value = var.docker_registry_htpasswd
  }

  set {
    name  = "secrets.haSharedSecret"
    value = data.vault_generic_secret.docker-registry-secrets.data["haSharedSecret"]
  }

}

locals {
  docker-registry-hosts = "docker-registry-k8s.${var.environment}.${var.zone}.com"
}

data "vault_generic_secret" "docker-registry-secrets" {
  path = "secret/helm/docker-registry"
}

variable "docker_registry_htpasswd" {
  type        = string
}
