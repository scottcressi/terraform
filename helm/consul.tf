resource "kubernetes_namespace" "consul" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "consul"
  }
}

resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = "0.24.1"
  namespace  = "consul"

  depends_on = [kubernetes_namespace.consul]
  values = [<<EOF
ui:
  service:
    type: ClusterIP
server:
  bootstrapExpect: ${var.consul_bootstrapExpect}
  replicas: ${var.consul_replicas}
EOF
  ]

}

variable "consul_bootstrapExpect" {
  type        = string
}

variable "consul_replicas" {
  type        = string
}
