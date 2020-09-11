resource "kubernetes_namespace" "jenkins" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "jenkins"
  version    = "1.27.0"
  namespace  = "jenkins"

  depends_on = [kubernetes_namespace.jenkins]

  values = [
    "${file("jenkins.yaml")}"
  ]

  set {
    name  = "master.JenkinsUrl"
    value = "http://jenkins-k8s.${var.environment}.${var.zone}.com"
  }

  set {
    name  = "master.HostName"
    value = "jenkins-k8s.${var.environment}.${var.zone}.com"
  }

  set {
    name  = "master.ingress.hostName"
    value = "jenkins-k8s.${var.environment}.${var.zone}.com"
  }

}
